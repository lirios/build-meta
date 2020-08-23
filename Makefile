SHELL=/bin/bash
ARCH?=$(shell uname -m | sed "s/^i.86$$/i686/")
BOOTSTRAP_ARCH?=$(shell uname -m | sed "s/^i.86$$/i686/")
ifeq ($(ARCH),i686)
QEMU_ARCH=i386
else ifeq ($(ARCH),ppc64le)
QEMU_ARCH=ppc64
else
QEMU_ARCH=$(ARCH)
endif

ARCH_OPTS=-o bootstrap_build_arch $(BOOTSTRAP_ARCH) -o target_arch $(ARCH)

ifeq ($(ARCH),arm)
ABI=gnueabi
else
ABI=gnu
endif

BST=bst --colors $(ARCH_OPTS)
QEMU=qemu-system-$(QEMU_ARCH)

### VM

VM_CHECKOUT_ROOT=checkout/$(ARCH)
VM_ARTIFACT_ROOT?=vm/minimal/image.bst
VM_ARTIFACT_BOOT?=vm/boot/image.bst

clean-vm:
	rm -rf $(VM_CHECKOUT_ROOT)/$(VM_ARTIFACT_ROOT)
	rm -rf $(VM_CHECKOUT_ROOT)/$(VM_ARTIFACT_BOOT)

$(VM_CHECKOUT_ROOT)/$(VM_ARTIFACT_ROOT):
	$(BST) build $(VM_ARTIFACT_ROOT)
	$(BST) checkout --hardlinks $(VM_ARTIFACT_ROOT) $(VM_CHECKOUT_ROOT)/$(VM_ARTIFACT_ROOT)
$(VM_CHECKOUT_ROOT)/$(VM_ARTIFACT_BOOT):
	$(BST) build $(VM_ARTIFACT_BOOT)
	$(BST) checkout --hardlinks $(VM_ARTIFACT_BOOT) $(VM_CHECKOUT_ROOT)/$(VM_ARTIFACT_BOOT)

build-vm: clean-vm $(VM_CHECKOUT_ROOT)/$(VM_ARTIFACT_ROOT) $(VM_CHECKOUT_ROOT)/$(VM_ARTIFACT_BOOT)

### QEMU

QEMU_COMMON_ARGS= \
	-smp 4 \
	-m 256 \
	-nographic \
	-kernel $(VM_CHECKOUT_ROOT)/$(VM_ARTIFACT_BOOT)/vmlinuz \
	-initrd $(VM_CHECKOUT_ROOT)/$(VM_ARTIFACT_BOOT)/initramfs.gz \
	-virtfs local,id=virtfs,path=$(VM_CHECKOUT_ROOT)/$(VM_ARTIFACT_ROOT),security_model=none,mount_tag=virtfs

QEMU_X86_COMMON_ARGS= \
	$(QEMU_COMMON_ARGS) \
	-enable-kvm \
	-append 'root=virtfs rw rootfstype=9p rootflags=trans=virtio,version=9p2000.L,cache=mmap console=ttyS0'

QEMU_ARM_COMMON_ARGS= \
	$(QEMU_COMMON_ARGS) \
	-machine type=virt \
	-cpu max \
	-append 'root=virtfs rw rootfstype=9p rootflags=trans=virtio,version=9p2000.L,cache=mmap init=/usr/lib/systemd/systemd console=ttyAMA0'

QEMU_AARCH64_ARGS= \
	$(QEMU_ARM_COMMON_ARGS)

QEMU_ARM_ARGS= \
	$(QEMU_ARM_COMMON_ARGS) \
	-machine highmem=off

QEMU_PPC64LE_ARGS= \
	$(QEMU_COMMON_ARGS) \
	-machine pseries \
	-append 'root=virtfs rw rootfstype=9p rootflags=trans=virtio,version=9p2000.L,cache=mmap init=/usr/lib/systemd/systemd console=ttyS0'

run-vm: $(VM_CHECKOUT_ROOT)/$(VM_ARTIFACT_BOOT) $(VM_CHECKOUT_ROOT)/$(VM_ARTIFACT_ROOT)
ifeq ($(ARCH),x86_64)
	fakeroot $(QEMU) $(QEMU_X86_COMMON_ARGS)
else ifeq ($(ARCH),i686)
	fakeroot $(QEMU) $(QEMU_X86_COMMON_ARGS)
else ifeq ($(ARCH),aarch64)
	fakeroot $(QEMU) $(QEMU_AARCH64_ARGS)
else ifeq ($(ARCH),arm)
	fakeroot $(QEMU) $(QEMU_ARM_ARGS)
else ifeq ($(ARCH),ppc64le)
	fakeroot $(QEMU) $(QEMU_PPC64LE_ARGS)
endif
