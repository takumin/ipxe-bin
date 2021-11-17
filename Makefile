################################################################################
# Build Targets
################################################################################

TARGETS :=
TARGETS += ipxe-floppy.dsk
TARGETS += ipxe-undionly.kpxe
TARGETS += ipxe-snponly-x86.efi
TARGETS += ipxe-snponly-x64.efi
TARGETS += ipxe-rpi-arm32.efi
TARGETS += ipxe-rpi-arm64.efi

################################################################################
# iPXE Commit Hash
################################################################################

IPXE_COMMIT := $(shell git submodule --quiet foreach git rev-parse HEAD)

################################################################################
# Release Notes
################################################################################

RELEASE_NOTES := [github.com/ipxe/ipxe@$(IPXE_COMMIT)](https://github.com/ipxe/ipxe/tree/$(IPXE_COMMIT))

################################################################################
# Default Targets
################################################################################

.PHONY: all
all: check binaries checksums licenses

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

.PHONY: ipxe-config-local-general.h
ipxe-config-local-general.h: ipxe/src/config/local/general.h
ipxe/src/config/local/general.h:
	@{ \
		echo '/* Disabled Boot Wait */'; \
		echo '#undef BANNER_TIMEOUT'; \
		echo '#define BANNER_TIMEOUT 0'; \
		echo ''; \
		echo '/* Available Commands */'; \
		echo '#define NSLOOKUP_CMD /* DNS Resolving Command */'; \
		echo '#define NTP_CMD      /* NTP Command */'; \
		echo '#define PING_CMD     /* Ping Command */'; \
		echo '#define REBOOT_CMD   /* Reboot Command */'; \
		echo '#define POWEROFF_CMD /* Power Off Command */'; \
	} > $@

.PHONY: ipxe-config-local-nap.h
ipxe-config-local-nap.h: ipxe/src/config/local/nap.h
ipxe/src/config/local/nap.h:
	@{ \
		echo '/* Disabled CPU Sleeping */'; \
		echo '/* Hardware Measures Missing Interrupt Support */'; \
		echo '/* See also: https://u-boot.readthedocs.io/en/latest/develop/uefi/iscsi.html */'; \
		echo '#undef NAP_PCBIOS'; \
		echo '#undef NAP_EFIX86'; \
		echo '#undef NAP_EFIARM'; \
		echo '#define NAP_NULL'; \
	} > $@

.PHONY: ipxe-floppy.dsk
ipxe-floppy.dsk: bin/ipxe-floppy.dsk
bin/ipxe-floppy.dsk: ipxe/src/bin/ipxe.dsk bindir
	@install $< $@
ipxe/src/bin/ipxe.dsk: ipxe-config-local-general.h ipxe-config-local-nap.h
	@make -C ipxe/src -j $(shell nproc) $(subst ipxe/src/,,$@)

.PHONY: ipxe-undionly.kpxe
ipxe-undionly.kpxe: bin/ipxe-undionly.kpxe
bin/ipxe-undionly.kpxe: ipxe/src/bin/undionly.kpxe bindir
	@install $< $@
ipxe/src/bin/undionly.kpxe: ipxe-config-local-general.h ipxe-config-local-nap.h
	@make -C ipxe/src -j $(shell nproc) $(subst ipxe/src/,,$@)

.PHONY: ipxe-snponly-x86.efi
ipxe-snponly-x86.efi: bin/ipxe-snponly-x86.efi
bin/ipxe-snponly-x86.efi: ipxe/src/bin-i386-efi/snponly.efi bindir
	@install $< $@
ipxe/src/bin-i386-efi/snponly.efi: ipxe-config-local-general.h ipxe-config-local-nap.h
	@make -C ipxe/src -j $(shell nproc) $(subst ipxe/src/,,$@)

.PHONY: ipxe-snponly-x64.efi
ipxe-snponly-x64.efi: bin/ipxe-snponly-x64.efi
bin/ipxe-snponly-x64.efi: ipxe/src/bin-x86_64-efi/snponly.efi bindir
	@install $< $@
ipxe/src/bin-x86_64-efi/snponly.efi: ipxe-config-local-general.h ipxe-config-local-nap.h
	@make -C ipxe/src -j $(shell nproc) $(subst ipxe/src/,,$@)

.PHONY: ipxe-rpi-arm32.efi
ipxe-rpi-arm32.efi: bin/ipxe-rpi-arm32.efi
bin/ipxe-rpi-arm32.efi: ipxe/src/bin-arm32-efi/snp.efi bindir
	@install $< $@
ipxe/src/bin-arm32-efi/snp.efi: ipxe-config-local-general.h ipxe-config-local-nap.h
	@make -C ipxe/src -j $(shell nproc) CONFIG=rpi CROSS=arm-linux-gnueabihf- $(subst ipxe/src/,,$@)

.PHONY: ipxe-rpi-arm64.efi
ipxe-rpi-arm64.efi: bin/ipxe-rpi-arm64.efi
bin/ipxe-rpi-arm64.efi: ipxe/src/bin-arm64-efi/snp.efi bindir
	@install $< $@
ipxe/src/bin-arm64-efi/snp.efi: ipxe-config-local-general.h ipxe-config-local-nap.h
	@make -C ipxe/src -j $(shell nproc) CONFIG=rpi CROSS=aarch64-linux-gnu- $(subst ipxe/src/,,$@)

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
# License Targets
################################################################################

.PHONY: licenses
licenses: COPYING COPYING.GPLv2 COPYING.UBDL

.PHONY: COPYING
COPYING: bin/COPYING
bin/COPYING:
	@install $(subst bin/,ipxe/,$@) $@

.PHONY: COPYING.GPLv2
COPYING.GPLv2: bin/COPYING.GPLv2
bin/COPYING.GPLv2:
	@install $(subst bin/,ipxe/,$@) $@

.PHONY: COPYING.UBDL
COPYING.UBDL: bin/COPYING.UBDL
bin/COPYING.UBDL:
	@install $(subst bin/,ipxe/,$@) $@

################################################################################
# Release Targets
################################################################################

.PHONY: release
release: all
	@gh auth status 1>/dev/null 2>&1 || exit 1
	@gh release create "v$(shell date '+%Y%m%d')" -n "$(RELEASE_NOTES)" $(wildcard bin/*)

################################################################################
# Clean Targets
################################################################################

.PHONY: clean
clean:
	@rm -fr bin
	@git -C ipxe/src clean -xdf .
