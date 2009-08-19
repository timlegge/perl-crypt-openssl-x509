#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <openssl/asn1.h>
#include <openssl/objects.h>
#include <openssl/bio.h>
#include <openssl/crypto.h>
#include <openssl/err.h>
#include <openssl/evp.h>
#include <openssl/pem.h>
#include <openssl/x509.h>
#include <openssl/x509v3.h>

/* from openssl/apps/apps.h */
#define FORMAT_UNDEF    0
#define FORMAT_ASN1     1
#define FORMAT_TEXT     2
#define FORMAT_PEM      3
#define FORMAT_NETSCAPE 4
#define FORMAT_PKCS12   5
#define FORMAT_SMIME    6
#define FORMAT_ENGINE   7
#define FORMAT_IISSGC   8

#define NETSCAPE_CERT_HDR "certificate"

/* fake our package name */
typedef X509*	Crypt__OpenSSL__X509;
typedef X509_EXTENSION* Crypt__OpenSSL__X509__Extension;
typedef ASN1_OBJECT* Crypt__OpenSSL__X509__ObjectID;
typedef X509_NAME* Crypt__OpenSSL__X509__Name;
typedef X509_NAME_ENTRY* Crypt__OpenSSL__X509__Name_Entry;

/* stolen from OpenSSL.xs */
long bio_write_cb(struct bio_st *bm, int m, const char *ptr, int l, long x, long y) {

        if (m == BIO_CB_WRITE) {
                SV *sv = (SV *) BIO_get_callback_arg(bm);
                sv_catpvn(sv, ptr, l);
        }

        if (m == BIO_CB_PUTS) {
                SV *sv = (SV *) BIO_get_callback_arg(bm);
                l = strlen(ptr);
                sv_catpvn(sv, ptr, l);
        }

        return l;
}

static BIO* sv_bio_create(void) {

        SV *sv = newSVpvn("", 0);

	/* create an in-memory BIO abstraction and callbacks */
        BIO *bio = BIO_new(BIO_s_mem());

        BIO_set_callback(bio, bio_write_cb);
        BIO_set_callback_arg(bio, (void *)sv);

        return bio;
}

static SV* sv_bio_final(BIO *bio) {

	SV* sv;

	BIO_flush(bio);
	sv = (SV *)BIO_get_callback_arg(bio);
	BIO_free_all(bio);

	return sv;
}

static SV* sv_bio_utf8_on(BIO *bio) {
	SV* sv;
	sv = (SV *)BIO_get_callback_arg(bio);
	SvUTF8_on(sv);
	return sv;
}

/*
static void sv_bio_error(BIO *bio) {

	SV* sv = (SV *)BIO_get_callback_arg(bio);
	if (sv) sv_free(sv);

	BIO_free_all (bio);
}
*/

static const char *ssl_error(void) {
	BIO *bio;
	SV *sv;
	STRLEN l;

	bio = sv_bio_create();
	ERR_print_errors(bio);
	sv = sv_bio_final(bio);
	ERR_clear_error();
	return SvPV(sv, l);
}

// Make a scalar ref to a class object
static SV* sv_make_ref(const char* class, void* object) {
    SV* rv;

    rv = newSV(0);
    sv_setref_pv(rv, class, (void*) object);
    if (! sv_isa(rv, class) ){
       croak("Error creating reference to %s", class);
    }
    return rv;
}

/*
 * hash of extensions from x509.
 * no_name can be
 *  0: index by long name,
 *  1: index by oid string,
 *  2: index by short name
*/
static HV* hv_exts(X509* x509, int no_name) {
    X509_EXTENSION *ext;
    int i, c, r;
    size_t len = 128;
    char* key;
    SV* rv;

    HV* RETVAL = newHV();
    sv_2mortal((SV*)RETVAL);
    c = X509_get_ext_count(x509);
    if ( ! c > 0 ) {
        croak("No extensions found\n");
    }
    for(i = 0; i < c; i++) {
        r = 0;

        ext = X509_get_ext(x509, i);
        if (ext == NULL) croak("Extension %d unavailable\n", i);
        rv = sv_make_ref("Crypt::OpenSSL::X509::Extension", (void*)ext);
        if(no_name == 0 || no_name == 1) {
           key = malloc(sizeof(char) * (len + 1)); /*FIXME will it leak?*/
           r = OBJ_obj2txt(key, len, X509_EXTENSION_get_object(ext), no_name);
        } else if (no_name == 2) {
           key = OBJ_nid2sn(OBJ_obj2nid(X509_EXTENSION_get_object(ext)));
           r = strlen(key);
        }
        if (! hv_store(RETVAL, key, r, rv, 0) ) croak("Error storing extension in hash\n");
    }

    return RETVAL;
}


MODULE = Crypt::OpenSSL::X509		PACKAGE = Crypt::OpenSSL::X509

PROTOTYPES: DISABLE

BOOT:
{
	OpenSSL_add_all_algorithms();
        OpenSSL_add_all_ciphers();
        OpenSSL_add_all_digests();
	ERR_load_PEM_strings();
        ERR_load_ASN1_strings();
        ERR_load_crypto_strings();
        ERR_load_X509_strings();
        ERR_load_DSA_strings();
        ERR_load_RSA_strings();
        ERR_load_OBJ_strings();

	HV *stash = gv_stashpvn("Crypt::OpenSSL::X509", 20, TRUE);

	struct { char *n; I32 v; } Crypt__OpenSSL__X509__const[] = {

	{"FORMAT_UNDEF", FORMAT_UNDEF},
	{"FORMAT_ASN1", FORMAT_ASN1},
	{"FORMAT_TEXT", FORMAT_TEXT},
	{"FORMAT_PEM", FORMAT_PEM},
	{"FORMAT_NETSCAPE", FORMAT_NETSCAPE},
	{"FORMAT_PKCS12", FORMAT_PKCS12},
	{"FORMAT_SMIME", FORMAT_SMIME},
	{"FORMAT_ENGINE", FORMAT_ENGINE},
	{"FORMAT_IISSGC", FORMAT_IISSGC},
        {"V_ASN1_PRINTABLESTRING",  V_ASN1_PRINTABLESTRING},
        {"V_ASN1_UTF8STRING",  V_ASN1_UTF8STRING},
        {"V_ASN1_IA5STRING",  V_ASN1_IA5STRING},
	{Nullch,0}};

	char *name;
	int i;

	for (i = 0; (name = Crypt__OpenSSL__X509__const[i].n); i++) {
		newCONSTSUB(stash, name, newSViv(Crypt__OpenSSL__X509__const[i].v));
	}
}

Crypt::OpenSSL::X509
new(class)
	SV	*class

	CODE:

  	if ((RETVAL = X509_new()) == NULL) {
		croak("X509_new");
	}

        if (!X509_set_version(RETVAL, 2)) {
		X509_free(RETVAL);
		croak ("%s - can't X509_set_version()", class);
	}

	ASN1_INTEGER_set(X509_get_serialNumber(RETVAL), 0L);

	OUTPUT:
        RETVAL

Crypt::OpenSSL::X509
new_from_string(class, string, format = FORMAT_PEM)
	SV	*class
        SV	*string
        int	format

	ALIAS:
   	new_from_file = 1

	PREINIT:
	BIO *bio;
	STRLEN len;
	char *cert;

	CODE:

	cert = SvPV(string, len);

        if (ix == 1) {
		bio = BIO_new_file(cert, "r");
        } else {
		bio = BIO_new_mem_buf(cert, len);
	}

	if (!bio) croak("%s: Failed to create BIO", class);

	/* this can come in any number of ways */
	if (format == FORMAT_ASN1) {

                RETVAL = (X509*)d2i_X509_bio(bio, NULL);

        } else {

        	RETVAL = (X509*)PEM_read_bio_X509(bio, NULL, NULL, NULL);
        }

	if (!RETVAL) croak("%s: failed to read X509 certificate.", SvPV_nolen(class));

        BIO_free(bio);

	OUTPUT:
	RETVAL

void
DESTROY(x509)
	Crypt::OpenSSL::X509 x509;

	PPCODE:

	if (x509) X509_free(x509); x509 = 0;

SV*
accessor(x509)
	Crypt::OpenSSL::X509 x509;

	ALIAS:
	subject = 1
	issuer  = 2
	serial  = 3
	hash    = 4
	notBefore = 5
	notAfter  = 6
	email     = 7
        version   = 8
        sig_alg_name = 9

	PREINIT:
	BIO *bio;
	X509_NAME *name;

	CODE:

	bio = sv_bio_create();

	/* this includes both subject and issuer since they are so much alike */
        if (ix == 1 || ix == 2) {

		if (ix == 1) {
			name = X509_get_subject_name(x509);
		} else {
			name = X509_get_issuer_name(x509);
		}

                /* this need not be pure ascii, try to get a native perl character string with * utf8 */
		sv_bio_utf8_on(bio);

		/* this is prefered over X509_NAME_oneline() */
		X509_NAME_print_ex(bio, name, 0, (XN_FLAG_SEP_CPLUS_SPC | ASN1_STRFLGS_UTF8_CONVERT) & ~ASN1_STRFLGS_ESC_MSB);

	} else if (ix == 3) {

		i2a_ASN1_INTEGER(bio, x509->cert_info->serialNumber);

	} else if (ix == 4) {

		BIO_printf(bio, "%08lx", X509_subject_name_hash(x509));

	} else if (ix == 5) {

                ASN1_TIME_print(bio, X509_get_notBefore(x509));

	} else if (ix == 6) {

                ASN1_TIME_print(bio, X509_get_notAfter(x509));

	} else if (ix == 7) {

		int j;
		STACK *emlst = X509_get1_email(x509);

		for (j = 0; j < sk_num(emlst); j++) {
			BIO_printf(bio, "%s", sk_value(emlst, j));
		}

		X509_email_free(emlst);
	} else if (ix == 8) {

		i2a_ASN1_INTEGER(bio, x509->cert_info->version);

	} else if (ix == 9) {

                i2a_ASN1_OBJECT(bio, x509->sig_alg->algorithm);
        }

	RETVAL = sv_bio_final(bio);

	OUTPUT:
	RETVAL

Crypt::OpenSSL::X509::Name
subject_name(x509)
	Crypt::OpenSSL::X509 x509;

	ALIAS:
	subject_name = 1
	issuer_name  = 2

	CODE:
        if (ix == 1) {
            RETVAL = X509_get_subject_name(x509);
        } else {
            RETVAL = X509_get_issuer_name(x509);
        }

        OUTPUT:
        RETVAL

SV*
as_string(x509, format = FORMAT_PEM)
	Crypt::OpenSSL::X509 x509;
	int format;

	PREINIT:
	BIO *bio;

	CODE:

	bio = sv_bio_create();

	/* get the certificate back out in a specified format. */

	if (format == FORMAT_PEM) {

		PEM_write_bio_X509(bio, x509);

	} else if (format == FORMAT_ASN1) {

		i2d_X509_bio(bio, x509);

	} else if (format == FORMAT_NETSCAPE) {

		ASN1_HEADER ah;
		ASN1_OCTET_STRING os;

		os.data   = (unsigned char *)NETSCAPE_CERT_HDR;
		os.length = strlen(NETSCAPE_CERT_HDR);
		ah.header = &os;
		ah.data   = (char *)x509;
		ah.meth   = X509_asn1_meth();

		ASN1_i2d_bio(i2d_ASN1_HEADER, bio, (unsigned char *)&ah);
	}

	RETVAL = sv_bio_final(bio);

	OUTPUT:
	RETVAL

SV*
modulus(x509)
	Crypt::OpenSSL::X509 x509;

	PREINIT:
	EVP_PKEY *pkey;
	BIO *bio;

	CODE:

	pkey = X509_get_pubkey(x509);
	bio  = sv_bio_create();

	if (pkey == NULL) {

		BIO_free_all(bio);
		EVP_PKEY_free(pkey);
		croak("Modulus is unavailable\n");
	}

	if (pkey->type == EVP_PKEY_RSA) {

		BN_print(bio, pkey->pkey.rsa->n);

	} else if (pkey->type == EVP_PKEY_DSA) {

		BN_print(bio, pkey->pkey.dsa->pub_key);

	} else {

		BIO_free_all(bio);
		EVP_PKEY_free(pkey);
		croak("Wrong Algorithm type\n");
	}

	RETVAL = sv_bio_final(bio);

	EVP_PKEY_free(pkey);

	OUTPUT:
	RETVAL

SV*
fingerprint_md5(x509)
	Crypt::OpenSSL::X509 x509;

	ALIAS:
	fingerprint_md2  = 1
	fingerprint_sha1 = 2

	PREINIT:

        const EVP_MD *mds[] = { EVP_md5(), EVP_md2(), EVP_sha1() };
	unsigned char md[EVP_MAX_MD_SIZE];
        int i;
	unsigned int n;
	BIO *bio;

	CODE:

	bio  = sv_bio_create();

	if (!X509_digest(x509, mds[ix], md, &n)) {

		BIO_free_all(bio);
		croak("Digest error: %s", ssl_error());
	}

	BIO_printf(bio, "%02X", md[0]);
	for (i = 1; i < n; i++) {
		BIO_printf(bio, ":%02X", md[i]);
	}

	RETVAL = sv_bio_final(bio);

	OUTPUT:
	RETVAL

SV*
checkend(x509, checkoffset)
	Crypt::OpenSSL::X509 x509;
	IV checkoffset;

	PREINIT:
	time_t now;

	CODE:

	now = time(NULL);

	/* given an offset in seconds, will the certificate be expired? */
	if (ASN1_UTCTIME_cmp_time_t(X509_get_notAfter(x509), now + (int)checkoffset) == -1) {
		RETVAL = &PL_sv_yes;
	} else {
		RETVAL = &PL_sv_no;
	}

	OUTPUT:
	RETVAL

SV*
pubkey(x509)
	Crypt::OpenSSL::X509 x509;

	PREINIT:
	EVP_PKEY *pkey;
	BIO *bio;

	CODE:

	pkey = X509_get_pubkey(x509);
	bio  = sv_bio_create();

	if (pkey == NULL) {

		BIO_free_all(bio);
		EVP_PKEY_free(pkey);
		croak("Public Key is unavailable\n");
	}

	if (pkey->type == EVP_PKEY_RSA) {

		PEM_write_bio_RSAPublicKey(bio, pkey->pkey.rsa);

	} else if (pkey->type == EVP_PKEY_DSA) {

		PEM_write_bio_DSA_PUBKEY(bio, pkey->pkey.dsa);

	} else {

		BIO_free_all(bio);
		EVP_PKEY_free(pkey);
		croak("Wrong Algorithm type\n");
	}

	EVP_PKEY_free(pkey);

	RETVAL = sv_bio_final(bio);

	OUTPUT:
	RETVAL

int
num_extensions(x509)
	Crypt::OpenSSL::X509 x509;
    CODE:
        RETVAL = X509_get_ext_count(x509);
    OUTPUT:
        RETVAL

Crypt::OpenSSL::X509::Extension
extension(x509, i)
	Crypt::OpenSSL::X509 x509;
        int i;

	PREINIT:
        X509_EXTENSION *ext;
        int c;

	CODE:
        ext = NULL;

        c = X509_get_ext_count(x509);
        if ( ! c > 0 ) {
            croak("No extensions found\n");
        } else if ( i >= c || i < 0) {
            croak("Requested extension index out of range\n");
        } else {
            ext = X509_get_ext(x509, i);
        }

	if (ext == NULL) {
            // X509_EXTENSION_free(ext); // not needed?
            croak("Extension unavailable\n");
	}

	RETVAL = ext;

	OUTPUT:
	RETVAL

HV*
extensions(x509)
        Crypt::OpenSSL::X509 x509
    ALIAS:
        extensions_by_long_name = 0
        extensions_by_oid = 1
        extensions_by_name = 2
    CODE:
        RETVAL = hv_exts(x509, ix);
    OUTPUT:
        RETVAL


MODULE = Crypt::OpenSSL::X509		PACKAGE = Crypt::OpenSSL::X509::Extension

int
critical(ext)
        Crypt::OpenSSL::X509::Extension ext;

	CODE:

	if (ext == NULL) {
            croak("No extension supplied\n");
	}

	RETVAL = X509_EXTENSION_get_critical(ext);

	OUTPUT:
	RETVAL

Crypt::OpenSSL::X509::ObjectID
object(ext)
        Crypt::OpenSSL::X509::Extension ext;
    CODE:

	if (ext == NULL) {
            croak("No extension supplied\n");
	}

        RETVAL = X509_EXTENSION_get_object(ext);
    OUTPUT:
	RETVAL


SV*
value(ext)
        Crypt::OpenSSL::X509::Extension ext;
    PREINIT:
        BIO* bio;
    CODE:
        bio  = sv_bio_create();

	if (ext == NULL) {
            BIO_free_all(bio);
            croak("No extension supplied\n");
	}

        ASN1_STRING_print(bio, X509_EXTENSION_get_data(ext));

	RETVAL = sv_bio_final(bio);

    OUTPUT:
	RETVAL


MODULE = Crypt::OpenSSL::X509		PACKAGE = Crypt::OpenSSL::X509::ObjectID
char*
name(obj)
        Crypt::OpenSSL::X509::ObjectID obj;
    PREINIT:
        char buf[128];
        int r;
    CODE:
	if (obj == NULL) {
            croak("No ObjectID supplied\n");
	}
        r = OBJ_obj2txt(buf, 128, obj, 0);

	RETVAL = buf;

    OUTPUT:
	RETVAL

char*
oid(obj)
        Crypt::OpenSSL::X509::ObjectID obj;
    PREINIT:
        char buf[128];
        int r;
    CODE:
	if (obj == NULL) {
            croak("No ObjectID supplied\n");
	}
        r = OBJ_obj2txt(buf, 128, obj, 1);

	RETVAL = buf;

    OUTPUT:
	RETVAL

MODULE = Crypt::OpenSSL::X509		PACKAGE = Crypt::OpenSSL::X509::Name


SV*
as_string(name)
	Crypt::OpenSSL::X509::Name name;

    PREINIT:
	BIO *bio;

    CODE:
	bio = sv_bio_create();
        /* this is prefered over X509_NAME_oneline() */
        X509_NAME_print_ex(bio, name, 0, XN_FLAG_SEP_CPLUS_SPC);

	RETVAL = sv_bio_final(bio);

    OUTPUT:
	RETVAL

AV*
entries(name)
	Crypt::OpenSSL::X509::Name name;
    PREINIT:
        int i, c;
        SV* rv;
    CODE:
        RETVAL = newAV();
        sv_2mortal((SV*)RETVAL);

        c = X509_NAME_entry_count(name);
        for(i = 0; i < c; i++) {
            rv = sv_make_ref("Crypt::OpenSSL::X509::Name_Entry", (void*)X509_NAME_get_entry(name, i));
            av_push(RETVAL, rv);
        }

    OUTPUT:
        RETVAL

int
get_index_by_type(name, type, lastpos = -1)
	Crypt::OpenSSL::X509::Name name;
        const char* type;
        int lastpos;
        int ln;
    ALIAS:
        get_index_by_long_type = 1
        has_entry = 2
        has_long_entry = 3
        has_oid_entry = 4
        get_index_by_oid_type = 5
    PREINIT:
        int nid, i;
    CODE:
        if(ix == 1 || ix == 3) {
            nid = OBJ_ln2nid(type);
        } else if (ix == 4 || ix == 5) {
            nid = OBJ_obj2nid(OBJ_txt2obj(type, /*oid*/ 1));
        } else {
            nid = OBJ_sn2nid(type);
        }
        if(!nid)
            croak("Unknown type");

        i = X509_NAME_get_index_by_NID(name, nid, lastpos);
        if(ix == 2 || ix == 3 || ix == 4) { /* has_entry */
            RETVAL = (i > lastpos)?1:0;
        } else { /* get_index */
            RETVAL = i;
        }

    OUTPUT:
        RETVAL

Crypt::OpenSSL::X509::Name_Entry
get_entry_by_type(name, type, lastpos = -1)
	Crypt::OpenSSL::X509::Name name;
        const char* type;
        int lastpos;
        int ln;
    ALIAS:
        get_entry_by_long_type = 1
    PREINIT:
        int nid, i;
    CODE:
        if(ix == 1) {
            nid = OBJ_ln2nid(type);
        } else {
            nid = OBJ_sn2nid(type);
        }
        if(!nid)
            croak("Unknown type");

        i = X509_NAME_get_index_by_NID(name, nid, lastpos);
        RETVAL = X509_NAME_get_entry(name, i);

    OUTPUT:
        RETVAL


MODULE = Crypt::OpenSSL::X509		PACKAGE = Crypt::OpenSSL::X509::Name_Entry

SV*
as_string(name_entry, ln = 0)
	Crypt::OpenSSL::X509::Name_Entry name_entry;
        int ln;

    ALIAS:
        as_long_string = 1
    PREINIT:
	BIO *bio;
        char *n;
        int nid;

    CODE:
	bio = sv_bio_create();
        nid = OBJ_obj2nid(X509_NAME_ENTRY_get_object(name_entry));
        if(ix == 1 || ln) {
            n = OBJ_nid2ln(nid);
        } else {
            n = OBJ_nid2sn(nid);
        }
        BIO_printf(bio, "%s=", n);

        sv_bio_utf8_on(bio);

        ASN1_STRING_print_ex(bio, X509_NAME_ENTRY_get_data(name_entry), ASN1_STRFLGS_UTF8_CONVERT & ~ASN1_STRFLGS_ESC_MSB);
	RETVAL = sv_bio_final(bio);

    OUTPUT:
	RETVAL

SV*
type(name_entry, ln = 0)
	Crypt::OpenSSL::X509::Name_Entry name_entry;
        int ln;
    ALIAS:
        long_type = 1
    PREINIT:
	BIO *bio;
        char *n;
        int nid;

    CODE:
	bio = sv_bio_create();
        nid = OBJ_obj2nid(X509_NAME_ENTRY_get_object(name_entry));
        if(ix == 1 || ln) {
            n = OBJ_nid2ln(nid);
        } else {
            n = OBJ_nid2sn(nid);
        }
        BIO_printf(bio, "%s", n);
	RETVAL = sv_bio_final(bio);

    OUTPUT:
	RETVAL

SV*
value(name_entry)
	Crypt::OpenSSL::X509::Name_Entry name_entry;

    PREINIT:
	BIO *bio;

    CODE:
	bio = sv_bio_create();
        ASN1_STRING_print(bio, X509_NAME_ENTRY_get_data(name_entry));
	RETVAL = sv_bio_final(bio);

    OUTPUT:
	RETVAL

int
is_printableString(name_entry, asn1_type =  V_ASN1_PRINTABLESTRING)
        Crypt::OpenSSL::X509::Name_Entry name_entry;
        int asn1_type;

    ALIAS:
        is_asn1_type = 1
        is_printableString = V_ASN1_PRINTABLESTRING
        is_ia5string = V_ASN1_IA5STRING
        is_utf8string = V_ASN1_UTF8STRING

    CODE:
        RETVAL = (X509_NAME_ENTRY_get_data(name_entry)->type == (ix==1?asn1_type:ix));

    OUTPUT:
        RETVAL
