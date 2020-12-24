################################################################################
# Variables
################################################################################

TARGETS := undionly.kpxe snponly-x86.efi snponly-x64.efi rpi-arm32.efi rpi-arm64.efi

################################################################################
# Default Targets
################################################################################

.PHONY: all
all: check binaries checksums

################################################################################
# Build Targets
################################################################################

.PHONY: binaries
binaries: $(TARGETS)

.PHONY: bindir
bindir:
	@mkdir -p bin

.PHONY: check
check:
	@gcc -v 1>/dev/null 2>&1 || exit 1
	@arm-linux-gnueabihf-gcc -v 1>/dev/null 2>&1 || exit 1
	@aarch64-linux-gnu-gcc -v 1>/dev/null 2>&1 || exit 1

.PHONY: undionly.kpxe
undionly.kpxe: bin/undionly.kpxe
bin/undionly.kpxe: ipxe/src/bin/undionly.kpxe bindir
	@install $< $@
ipxe/src/bin/undionly.kpxe:
	@make -C ipxe/src -j $(nproc) $(subst ipxe/src/,,$@)

.PHONY: snponly-x86.efi
snponly-x86.efi: bin/snponly-x86.efi
bin/snponly-x86.efi: ipxe/src/bin-i386-efi/snponly.efi bindir
	@install $< $@
ipxe/src/bin-i386-efi/snponly.efi:
	@make -C ipxe/src -j $(nproc) $(subst ipxe/src/,,$@)

.PHONY: snponly-x64.efi
snponly-x64.efi: bin/snponly-x64.efi
bin/snponly-x64.efi: ipxe/src/bin-x86_64-efi/snponly.efi bindir
	@install $< $@
ipxe/src/bin-x86_64-efi/snponly.efi:
	@make -C ipxe/src -j $(nproc) $(subst ipxe/src/,,$@)

.PHONY: rpi-arm32.efi
rpi-arm32.efi: bin/rpi-arm32.efi
bin/rpi-arm32.efi: ipxe/src/bin-arm32-efi/rpi.efi bindir
	@install $< $@
ipxe/src/bin-arm32-efi/rpi.efi:
	@make -C ipxe/src -j $(nproc) CONFIG=rpi CROSS=arm-linux-gnueabihf- $(subst ipxe/src/,,$@)

.PHONY: rpi-arm64.efi
rpi-arm64.efi: bin/rpi-arm64.efi
bin/rpi-arm64.efi: ipxe/src/bin-arm64-efi/rpi.efi bindir
	@install $< $@
ipxe/src/bin-arm64-efi/rpi.efi:
	@make -C ipxe/src -j $(nproc) CONFIG=rpi CROSS=aarch64-linux-gnu- $(subst ipxe/src/,,$@)

################################################################################
# Checksum Targets
################################################################################

.PHONY: checksums
checksums: MD5SUMS SHA1SUMS SHA256SUMS SHA512SUMS

.PHONY: MD5SUMS
MD5SUMS: bin/MD5SUMS
bin/MD5SUMS: $(TARGETS)
	@cd bin && md5sum $^ | tee $(subst bin/,,$@)

.PHONY: SHA1SUMS
SHA1SUMS: bin/SHA1SUMS
bin/SHA1SUMS: $(TARGETS)
	@cd bin && sha1sum $^ | tee $(subst bin/,,$@)

.PHONY: SHA256SUMS
SHA256SUMS: bin/SHA256SUMS
bin/SHA256SUMS: $(TARGETS)
	@cd bin && sha256sum $^ | tee $(subst bin/,,$@)

.PHONY: SHA512SUMS
SHA512SUMS: bin/SHA512SUMS
bin/SHA512SUMS: $(TARGETS)
	@cd bin && sha512sum $^ | tee $(subst bin/,,$@)

################################################################################
# Clean Targets
################################################################################

.PHONY: clean
clean:
	@rm -fr bin
	@git -C ipxe/src clean -xdf .
