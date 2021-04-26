package Lib::GMime;
# ABSTRACT: Perl interface to the GMime 3.0 MIME message parser and creator library

use strict;
use warnings;
use parent 'Exporter';
use experimental qw< signatures >;
use FFI::CheckLib 0.06 qw< find_lib_or_die >;
use FFI::Platypus;
use FFI::C;

## no critic qw(Modules::ProhibitMultiplePackages Variables::ProhibitPackageVars)

our $ffi       = FFI::Platypus->new( 'api' => 1 );
our @EXPORT_OK = qw< $ffi init shutdown >;

FFI::C->ffi($ffi);
$ffi->lib(
    find_lib_or_die( 'lib' => 'gobject-2.0' ),
    find_lib_or_die( 'lib' => 'gmime-3.0' ),
);

# Attach these before mangling

$ffi->attach(
    [ 'g_type_name_from_instance' => '_g_type_name_from_instance' ],
    ['opaque'],
    'string',
);

$ffi->attach(
    [ 'g_object_unref' => '_g_object_unref' ],
    ['opaque'],
    'void',
);

package Lib::GMime::Enum::RFComplianceMode {

    FFI::C->enum( 'GMimeRfcComplianceMode' => [ qw<
        RFC_COMPLIANCE_LOOSE
        RFC_COMPLIANCE_STRICT
    > ]);
}

package Lib::GMime::Enum::ParserWarning {

    FFI::C->enum( 'GMimeParserWarning' => [
        [ 'WARN_DUPLICATED_HEADER' => 1 ],
        qw<
           WARN_DUPLICATED_PARAMETER
           WARN_UNENCODED_8BIT_HEADER
           WARN_INVALID_CONTENT_TYPE
           WARN_INVALID_RFC2047_HEADER_VALUE
           WARN_MALFORMED_MULTIPART
           WARN_TRUNCATED_MESSAGE
           WARN_MALFORMED_MESSAGE
           CRIT_INVALID_HEADER_NAME
           CRIT_CONFLICTING_HEADER
           CRIT_CONFLICTING_PARAMETER
           CRIT_MULTIPART_WITHOUT_BOUNDARY
           WARN_INVALID_PARAMETER
           WARN_INVALID_ADDRESS_LIST
           CRIT_NESTING_OVERFLOW
        >,
    ]);
}

package Lib::GMime::Enum::Format {

    FFI::C->enum( 'GMimeFormat' => [ qw<
        FORMAT_MESSAGE
        FORMAT_MBOX
        FORMAT_MMDF
    > ]);
}

package Lib::GMime::Enum::SeekWhence {

    FFI::C->enum( 'GMimeSeekWhence' => [ qw<
        STREAM_SEEK_SET
        STREAM_SEEK_CUR
        STREAM_SEEK_END
    > ]);
}

package Lib::GMime::StreamIOVector {

    FFI::C->struct( 'GMimeStreamIOVector' => [
        'data' => 'opaque',
        'len'  => 'size_t',
    ]);
}

$ffi->mangler( sub ($symbol) {
    return "g_mime_$symbol";
});

$ffi->attach( 'init'     => [] => 'void' );
$ffi->attach( 'shutdown' => [] => 'void' );

1;

__END__

=pod

=head1 SYNOPSIS

    use Lib::GMime;
    Lib::GMime::init();

    # ... do stuff

    Lib::GMime::shutdown();

=head1 DESCRIPTION

Remains to be written.

=head1 SEE ALSO

Most of these are not written, but they are here so I remember to write
them.

=head2 Streams

=head3 L<Lib::GMime::Stream>

=head3 L<Lib::GMime::Stream::File>

=head3 L<Lib::GMime::Stream::Fs>

=head3 L<Lib::GMime::Stream::GIO>

=head3 L<Lib::GMime::Stream::Mem>

=head3 L<Lib::GMime::Stream::Mmap>

=head3 L<Lib::GMime::Stream::Null>

=head3 L<Lib::GMime::Stream::Filter>

=head3 L<Lib::GMime::Stream::Buffer>

=head3 L<Lib::GMime::Stream::Pipe>

=head3 L<Lib::GMime::Stream::Cat>

=head2 Stream Filters

=head3 L<Lib::GMime::Filter>

Abstract filter class.

=head3 L<Lib::GMime::Filter::Basic>

Basic transfer encoding filter.

=head3 L<Lib::GMime::Filter::Best>

Determine the best charset/encoding to use for a stream.

=head3 L<Lib::GMime::Filter::Charset>

Charset-conversion filter.

=head3 L<Lib::GMime::Filter::Checksum>

Calculate a checksum.

=head3 L<Lib::GMime::Filter::Dos2Unix>

Convert line-endings from Windows/DOS (CRLF) to UNIX (LF).

=head3 L<Lib::GMime::Filter::Enriched>

Convert text/enriched or text/rtf to HTML.

=head3 L<Lib::GMime::Filter::From>

Escape MBox C<From:> lines.

=head3 L<Lib::GMime::Filter::GZip>

GNU Zip compression/decompression.

=head3 L<Lib::GMime::Filter::HTML>

Convert plain text into HTML.

=head3 L<Lib::GMime::Filter::OpenPGP>

Detect OpenPGP markers.

=head3 L<Lib::GMime::Filter::SmtpData>

Byte-stuffs outgoing SMTP DATA.

=head3 L<Lib::GMime::Filter::Strip>

Strip trailing whitespace from the end of lines.

=head3 L<Lib::GMime::Filter::Unix2Dos>

Convert line-endings from UNIX (LF) to Windows/DOS (CRLF).

=head3 L<Lib::GMime::Filter::Windows>

Determine if text is in a Microsoft Windows codepage.

=head3 L<Lib::GMime::Filter::Yenc>

yEncode or yDecode.

=head2 Data Wrappers

=head3 L<Lib::GMime::DataWrapper>

Content objects .

=head2 Message and MIME Headers

=head3 L<Lib::GMime::HeaderList>

Message and MIME part headers.

=head3 L<Lib::GMime::ContentType>

Content-Type fields.

=head3 L<Lib::GMime::ContentDisposition>

Content-Disposition fields.

=head3 L<Lib::GMime::ParamList>

Content-Type and Content-Disposition parameters.

=head2 Internet Addresses

=head3 L<Lib::GMime::InternetAddress>

Internet addresses.

=head3 L<Lib::GMime::InternetAddressGroup>

rfc822 'group' address.

=head3 L<Lib::GMime::InternetAddressMailbox>

rfc822 'mailbox' address.

=head3 L<Lib::GMime::InternetAddressList>

A list of internet addresses.

=head2 MIME Messages and Parts

=head3 L<Lib::GMime::Object>

Abstract MIME objects.

=head3 L<Lib::GMime::Message>

Messages.

=head3 L<Lib::GMime::Part>

MIME parts.

=head3 L<Lib::GMime::TextPart>

textual MIME parts.

=head3 L<Lib::GMime::Multipart>

MIME multiparts.

=head3 L<Lib::GMime::Multipart::Encrypted>

Encrypted MIME multiparts.

=head3 L<Lib::GMime::Multipart::Signed>

Signed MIME multiparts.

=head3 L<Lib::GMime::Application::Pkcs7Mime>

Pkcs7 MIME parts.

=head3 L<Lib::GMime::Message::Part>

Message parts.

=head3 L<Lib::GMime::Message::Partial>

Partial MIME parts.

=head3 L<Lib::GMime::Part::Iterator>

MIME part iterators.

=head2 Parsing Messages and MIME Parts

=head3 L<Lib::GMime::Parser::Options>

Parser options.

=head3 L<Lib::GMime::Parser>

Message and MIME part parser.

=head2 Cryptography Contexts

=head3 L<Lib::GMime::Certificate>

Digital certificates.

=head3 L<Lib::GMime::Signature>

Digital signatures.

=head3 L<Lib::GMime::CryptoContext>

Encryption/signing contexts.

=head3 L<Lib::GMime::GpgContext>

GnuPG crypto contexts.

=head3 L<Lib::GMime::Pkcs7Context>

PKCS7 crypto contexts.
