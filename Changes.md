# Revision history for Perl extension Crypt::OpenSSL::X509

## 1.9.13 Sat Feb 26 00:36:28 CET 2022

- The distribution has changed distribution toolchain from Module::Install to Dist::Zilla, thanks to @skaji for PR [#96](https://github.com/dsully/perl-crypt-openssl-x509/pull/96) and thanks to @timlegge for the review of the proposed changes

- The macOS CI jobs have been improved with PRs [#98](https://github.com/dsully/perl-crypt-openssl-x509/pull/98) and [#99](https://github.com/dsully/perl-crypt-openssl-x509/pull/99) from @timlegge

## 1.9.13-TRIAL Sun Feb 20 21:31:44 CET 2022

- Release leading up to 1.9.13, see that release for details

- This is a TRIAL release, in order to get some feedback from CPAN-testers prior to making a proper public release, since the changes to the build system has been quite significant. Additional trial releases might follow, based on findings and feedback

## 1.9.12 Wed Jan 19 07:46:10 CET 2022

- Repair upload, see release 1.9.11, thank you @timlegge for reporting this

> PAUSE doesn't let you upload a file twice.

## 1.9.11 Tue Jan 18 18:57:39 CET 2022

- Applied patch from @jrouzierinverse PR [#93](https://github.com/dsully/perl-crypt-openssl-x509/pull/93) addressing issue [#66](https://github.com/dsully/perl-crypt-openssl-x509/issues/66)

- Applied patch from @timlegge PR [#92](https://github.com/dsully/perl-crypt-openssl-x509/pull/92) addressing issues [#50](https://github.com/dsully/perl-crypt-openssl-x509/issues/50) and [#40](https://github.com/dsully/perl-crypt-openssl-x509/issues/40)

- Correction to spelling found Debian Linter, thanks @fschlich PR [#90](https://github.com/dsully/perl-crypt-openssl-x509/pull/90)

- Added eliminated compound-token-split-by-macro errors coming from newer clang/LLVM version (>11?), got some good pointers from this [Perl issue](https://github.com/Perl/perl5/issues/18780)

- Forced OpenSSL under Homebrew to 1.1 via `openssl\@1.1`, since OpenSSL version 3 got released we might experience issues and this need to be revisited and tested thoroughly

- Reformatted the Changes file, slowly converting to Markdown

## 1.9.10 Sun Aug  1 09:48:08 CEST 2021

- MANIFEST was not updated with the latest contributions from 1.9.9, see issue [#89](https://github.com/dsully/perl-crypt-openssl-x509/issues/89)

## 1.9.9 Sat Jul 31 17:58:56 CEST 2021

- Contribution by Patrick Cernko. The email method has been extended to return multiple email addresses if available.
  The addresses are concatenated using space (' ') as seperator in order for consumers to extract the multiple email addresses, see PR [#88](https://github.com/dsully/perl-crypt-openssl-x509/pull/88)

## 1.9.8 Thu May 13 18:04:17 CEST 2021

- Addressed minor issue, via PR [#87](https://github.com/dsully/perl-crypt-openssl-x509/pull/87), with the implementation added in 1.9.3 - Thanks Shoichi Kaji

## 1.9.7 Sun May  2 19:36:24 CEST 2021

- Addressed minor issue with META.yml file not reporting correct version, see issue [#86](https://github.com/dsully/perl-crypt-openssl-x509/issues/86)

## 1.9.6 Sat Apr 24 09:17:00 CEST 2021

- I fell over this [CPAN release checklist](https://github.com/Tux/Release-Checklist/blob/master/Checklist.md), it mentions
  [Devel::PPPort](https://metacpan.org/pod/Devel::PPPort). I have now put this to use, raised a single warning

  ```text
  *** WARNING: Uses is_utf8_string_loclen, which may not be portable below perl 5.9.3, even with 'ppport.h'
  *** Uses 5 C++ style comments, which is not portable
  Analysis completed (1 warning)
  ```

  And provided as single patch, which has now been applied and C++ style comments have been changed to C style comments

## 1.9.5 Thu Apr 22 07:32:16 CEST 2021

- I broke the build for Linux

  - [CPAN testers reports](http://matrix.cpantesters.org/?dist=Crypt-OpenSSL-X509+1.904)

    The issue is that the change introduced in 1.9.4 introduces an option, which is LLVM specific
    and is not understood by GCC.

    See also issue: [#84](https://github.com/dsully/perl-crypt-openssl-x509/issues/84)

    I have rearranged the use of flags and try with a match on the GCC version string, which
    can contain the substring LLVM

## 1.9.4 Wed Apr 21 07:45:58 CEST 2021

- Made a minor change to the Makefile.PL addressing issue with breaking builds on FreeBSD and OpenBSD

  For Perl versions below or equal to 5.20, the error:

  ```text
  error: nonnull parameter 'pv' will evaluate to 'true' on first encounter [-Werror,-Wpointer-bool-conversion]
  if (pv && len > 1) {
  ```

  Has been observed this is now suppressed with converting the error handling into a warning

  See CPAN testers reports: [1](http://www.cpantesters.org/cpan/report/119b4298-9e42-11eb-84bc-edd243e66a77), [2](http://www.cpantesters.org/cpan/report/77bdcdd2-a0e7-11eb-84bc-edd243e66a77) and [3](http://www.cpantesters.org/cpan/report/fd7e66b6-a14b-11eb-84bc-edd243e66a77)

## 1.9.3 Thu Apr  8 07:43:10 CEST 2021

- Addressed issue [#81](https://github.com/dsully/perl-crypt-openssl-x509/issues/81) based on proposed patch from Shoichi Kaji

## 1.9.2 Thu Nov 12 07:27:56 CET 2020

- Addressed issue [#84](https://github.com/dsully/perl-crypt-openssl-x509/issues/84) via PR [#73](https://github.com/dsully/perl-crypt-openssl-x509/pull/73) removing and excess use of free

## 1.9.1 Fri Nov  6 19:53:21 CET 2020

- Corrected version number format to address issue [#77](https://github.com/dsully/perl-crypt-openssl-x509/issues/77) via PR [#78](https://github.com/dsully/perl-crypt-openssl-x509/pull/78)

## 1.9 Thu Nov  5 21:38:43 CET 2020

- Bumped Perl minimum requirement from Perl 5.005 to 5.8 PR [#76](https://github.com/dsully/perl-crypt-openssl-x509/pull/76)

- Changed from use vars definition to the more modern our PR: [#75](https://github.com/dsully/perl-crypt-openssl-x509/pull/75) Thanks to Todd Rinaldo

- Changed from DynaLoader to XSLoader PR: [#75](https://github.com/dsully/perl-crypt-openssl-x509/pull/75) Thanks to Todd Rinaldo

## 1.8.13 Thu Oct 24 21:23:46 CEST 2019

- Ensure `/usr/local` is ahead of `/usr` in include and lib searches, PR: [#74](https://github.com/dsully/perl-crypt-openssl-x509/pull/74)

## 1.8.12 Thu Nov 22 19:54:37 CET 2018

- Applied patch from @eserte addressing issue (#71) with [current directory no longer included in `@INC` by default from Perl 5.26](https://www.effectiveperlprogramming.com/2017/01/v5-26-removes-dot-from-inc/)

## 1.8.11 Sun Oct 28 20:22:59 CET 2018

- Re-release of 1.8.10, with corrected version number, indexer error from PAUSE

## 1.8.10 Sun Oct 28 16:52:50 CET 2018

- Maintenance release, corrected [issue with `MYMETA.*` files included in distribution](https://weblog.bulknews.net/stop-shipping-mymeta-to-cpan-b92215a227f6)

## 1.8.9 Tue May 30 2017

- Patch / PR from kmx improving detection of OpenSSL libraries under strawberry Perl

## 1.8.8 Fri Nov 10 2017

- Patch from pi-rho exposing the Issuer's name hash; provide `subject_hash()` as an alias to `hash()`

- Patch from stphnlyd `X509_get0_signature()` was introduced to [OpenSSL](https://www.openssl.org/docs/man1.1.0/crypto/X509_get0_signature.html) since 1.0.2.

- Patch from brandond fixing compilation on OpenSSL 1.0.1e

- Patch to support compilation on MacOS Homebrew installed libraries by jonasbn

- Patch from ppisar, patch redefines the accessors only with OpenSSL older than 1.1.0

- Patch from Sebastian Andrzej Siewior fixing compilation against openssl 1.1.0 and keeping it working against openssl 1.0.2j

- Patch from jonasbn reinitializing `inc/` using Module::Install 1.16, fixed issue with `META.ym` version since `META.yml` was not regenerated

## 1.8.7  Thu May 12 2016

- Patch from Bernhard M. Wiedemann to fix compilation errors

## 1.8.6  Sat Jan 24 2015

- Patch from James Hunt to print OpenSSL version during tests

- Various `MANIFEST` fixes

## 1.8.5  Sat Nov 22 2014

- Patch from Uli Scholler to expose more SHA1 hash functions

## 1.8.4  Sun Dec 1 2013

- Fix Github Issues [#16](https://github.com/dsully/perl-crypt-openssl-x509/issues/16) , [#29](https://github.com/dsully/perl-crypt-openssl-x509/issues/29) & [#30](https://github.com/dsully/perl-crypt-openssl-x509/issues/30)

- Possibly fix issue [#31](https://github.com/dsully/perl-crypt-openssl-x509/issues/31)

## 1.8.3  Mon Aug 12 05:50:58 PDT 2013

- Fix Github Issues [#2](https://github.com/dsully/perl-crypt-openssl-x509/issues/2), [#10](https://github.com/dsully/perl-crypt-openssl-x509/issues/10), [#15](https://github.com/dsully/perl-crypt-openssl-x509/issues/15) , [#17](https://github.com/dsully/perl-crypt-openssl-x509/issues/17), [#22](https://github.com/dsully/perl-crypt-openssl-x509/issues/22), [#23](https://github.com/dsully/perl-crypt-openssl-x509/issues/23), [#24](https://github.com/dsully/perl-crypt-openssl-x509/issues/24) & [#25](https://github.com/dsully/perl-crypt-openssl-x509/issues/25)

## 1.8.2  Sat May  7 20:19:58 PDT 2011

- Fix warnings under gcc 4.6

## 1.8.1  Sun Apr 17 06:57:09 PDT 2011

- Fix OpenSSL version check.

## 1.8    Wed Apr 13 06:22:30 PDT 2011

- Bump version to deal with CPAN/Perl versioning madness.

## 1.7.1  Tue Apr  5 20:07:48 PDT 2011

- Fix compile issue on i386, etc.

## 1.7    Tue Mar 29 19:58:08 PDT 2011

- Updates from David O'Callaghan to add pubkey, encoding & CRL functions.

## 1.6    Wed Jan  5 10:04:08 PST 2011

- Fix from Nicholas Harteau for -Wall error. Exhibited by `-O2`
- Update home page & bug tracker.

## 1.5    Fri Dec 24 14:39:20 PST 2010

- Fix call to utf_loclen to be compatible with CentOS Perl. (CPAN RT #62339)

- Update Module::Install

## 1.4    Tue Aug 31 07:13:20 PDT 2010

- Fix `new_from_string()?

## 1.3    Fri Aug  6 09:18:30 PDT 2010

- Fix `fingerprint_sha1()`

## 1.2    Mon May 31 05:59:03 PDT 2010

- Compatible with OpenSSL v1.0.0

- Incompatible change: Removed fingerprint_md2 method

- Fix leaked memory on module END

## 1.1    Fri May 21 17:10:28 PDT 2010

- Fix memory leak in sv_bio_final() (CPAN RT #57719)

## 1.0    Mon Jan 18 12:49:11 PST 2010

- Remove pub_exponent() and alias it to exponent().

## 0.9    Mon Jan 18 11:02:26 PST 2010

- Patches from David O'Callaghan to access X509 extensions & documenation.

- Patch from Otmar Lendl to allow UTF-8 chars in certificate names.

- Patches from Louise Doran via David O'Callaghan.

- Patch from Daniel Kahn Gillmor adding more examples in the POD SYNOPSIS

- Patch from Daniel Kahn Gillmor adding the exponent() method.

## 0.8    Sat Nov  8 15:40:02 PST 2008

- Fix error message

## 0.7    Sat May 17 00:49:28 PDT 2008

- Stop cpansmoke if libcrypto isn't installed.

## 0.6    Sat Feb 23 14:18:30 PST 2008

- RT #28684: Failed test 'use Crypt::OpenSSL::X509;'

## 0.5    Sat Jun  2 11:12:03 PDT 2007

- Fix manifest.

## 0.4    Wed Jan  3 17:19:10 PST 2007

- RT #13861 - patch from dsteinwand@citysearch.com

- RT #8778  - Fix flags for `X509_NAME_print_ex()`

## 0.3.1  Mon Nov 22 23:20:43 PST 2004

- Patch from Daniel Risacher to add an `email()` method & doc additions

- Remove newline from hash() accessor

## 0.3   Mon Oct  4 12:38:34 PDT 2004

- Patch from Otmar Lendl to remove `NULL` on fingerprint

## 0.2   Fri Jan 30 11:36:36 PST 2004

- Handle ASN1/DER input

- Additional headers and cleanup

## 0.1   Thu Jan 29 17:01:38 PST 2004

- Initial release

- Interoperates with Crypt::OpenSSL::Bignum & Crypt::OpenSSL::RSA

## 0.01  Wed Jan 28 15:53:18 2004

- original version; created by h2xs 1.22 with options
  `-O -b 5.5.3 -a -k --skip-ppport --skip-warnings -c -n Crypt::OpenSSL::X509`
