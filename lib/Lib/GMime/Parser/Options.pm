package Lib::GMime::Parser::Options;
# ABSTRACT:

use strict;
use warnings;
use experimental qw< signatures >;
use Carp ();
use Lib::GMime qw< $ffi >;

my $opt_cb = (
    'address_compliance_mode'        => 'set_address_compliance_mode'
    'allow_addresses_without_domain' => 'set_allow_addresses_without_domain',
    'parameter_compliance_mode'      => 'set_parameter_compliance_mode',
    'rfc2047_compliance_mode'        => 'set_rfc2047_compliance_mode',
    'fallback_charsets'              => 'set_fallback_charsets',
    'warning_callback'               => 'set_warning_callback',
);

# TODO
sub get_warning_callback {...}
sub set_warning_callback {...}

$ffi->attach(
    [ 'parser_options_new' => 'new' ],
    [],
    'opaque',
    sub ( $xsub, $class, $opts = {} ) {
        my $self = bless { $self->{'ptr'} = $xsub->() }, $class;

        foreach my $opt_name ( keys $opts->%* ) {
            my $opt_value   = $opts->{$opt_name};
            my $method_name = $opts_cb{$opt_name};
                or Carp::croak("Option '$opt_name' does not exist");

            $self->$method_name($opt_value);
        }

        return $self;
    }
);

$ffi->attach(
    [ 'parser_options_free' => 'DESTROY' ],
    ['opaque'],
    'void',
    sub ( $xsub, $self ) { $xsub->( $self->{'ptr'} ); },
);

$ffi->attach(
    [ 'parser_options_clone' => 'clone' ],
    ['opaque'],
    'opaque',
    sub ( $xsub, $self ) {
        return bless {
            'ptr' => $xsub->( $self->{'ptr'} ),
        }, 'Lib::GMime::Parser::Options';
    },
);

$ffi->attach(
    [ 'parser_options_get_default' => 'get_default' ],
    [],
    'opaque',
    sub ( $xsub, $class = '' ) {
        return bless { 'ptr' => $xsub->() }, 'Lib::GMime::Parser::Options';
    },
);

$ffi->attach(
    [ 'parser_options_get_address_compliance_mode' => 'get_address_compliance_mode' ],
    ['opaque'],
    'GMimeRfcComplianceMode',
    sub ( $xsub, $self ) { return $xsub->( $self->{'ptr'} ); },
);

$ffi->attach(
    [ 'parser_options_set_address_compliance_mode' => 'set_address_compliance_mode' ],
    [ 'opaque', 'GMimeRfcComplianceMode' ],
    'void',
    sub ( $xsub, $self, $mode ) { $xsub->( $self->{'ptr'}, $mode ); },
);

$ffi->attach(
    [ 'parser_options_get_allow_addresses_without_domain' => 'get_allow_addresses_without_domain' ],
    ['opaque'],
    'bool',
    sub ( $xsub, $self ) { return $xsub->( $self->{'ptr'} ); },
);

$ffi->attach(
    [ 'parser_options_set_allow_addresses_without_domain' => 'set_allow_addresses_without_domain' ],
    [ 'opaque', 'bool' ],
    'void',
    sub ( $xsub, $self, $allow ) { return $xsub->( $self->{'ptr'}, $allow ); },
);

$ffi->attach(
    [ 'parser_options_get_parameter_compliance_mode' => 'get_parameter_compliance_mode' ],
    ['opaque'],
    'GMimeRfcComplianceMode',
    sub ( $xsub, $self ) { return $xsub->( $self->{'ptr'} ); },
);

$ffi->attach(
    [ 'parser_options_set_parameter_compliance_mode' => 'set_parameter_compliance_mode' ],
    [ 'opaque', 'GMimeRfcComplianceMode' ],
    'void',
    sub ( $xsub, $self, $mode ) { return $xsub->( $self->{'ptr'}, $mode ); },
);

$ffi->attach(
    [ 'parser_options_get_rfc2047_compliance_mode' => 'get_rfc2047_compliance_mode' ],
    ['opaque'],
    'GMimeRfcComplianceMode',
    sub ( $xsub, $self ) { return $xsub->( $self->{'ptr'} ); },
);

$ffi->attach(
    [ 'parser_options_set_rfc2047_compliance_mode' => 'set_rfc2047_compliance_mode' ],
    [ 'opaque', 'GMimeRfcComplianceMode' ],
    'void',
    sub ( $xsub, $self, $mode ) { $xsub->( $self->{'ptr'}, $mode ); },
);

$ffi->attach(
    [ 'parser_options_get_fallback_charsets' => 'get_fallback_charsets' ],
    ['opaque'],
    'opaque',
    sub ( $xsub, $self ) {
        my $stringref = $xsub->( $self->{'ptr'} );
        return $ffi->cast( 'opaque*', 'string', $stringref );
    },
);

$ffi->attach(
    [ 'parser_options_set_fallback_charsets' => 'set_fallback_charsets' ],
    [ 'opaque', 'opaque' ],
    'void',
    sub ( $xsub, $self, $charsets ) { $xsub->( $self->{'ptr'}, \$charsets ); },
);

1;

__END__

=pod

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 C<new($opts)>

    my $parser_opts = Lib::GMime::Parser::Options->new({
        'address_compliance_mode'        => $addr_comp_mode,
        'allow_addresses_without_domain' => $allow_addr_no_domain,
        'parameter_compliance_mode'      => $param_comp_mode,
        'rfc2047_compliance_mode'        => $rfc_comp_mode,
        'fallback_charsets'              => $fallback_charsets,
        'warning_callback'               => $warning_cb,
    });

    # Same as:
    my $parser_opts = Lib::GMime::Parser::Options->new();
    $parser_opts->set_address_compliance_mode($addr_comp_mode);
    $parser_opts->set_allow_addresses_without_domain($allow_addr_no_domain);
    $parser_opts->set_parameter_compliance_mode($param_comp_mode);
    $parser_opts->set_rfc2047_compliance_mode($rfc_comp_mode);
    $parser_opts->set_fallback_charsets($fallback_charsets);
    $parser_opts->set_warning_callback($warning_cb);

Create a new set of parser options. This is what L<Lib::GMime::Parser>
uses. If you call L<Lib::GMime::Parser-&gt;new()> with options, it will
create such an object internally, because... you know, it's easier for you.

=head2 C<clone()>

    my $opts_clone = $parser_opts->clone();

Clones the object into a new object.

=head2 C<get_default()>

    # All the same:
    my $default_opts = $parser_opts->get_default();
    my $default_opts = Lib::GMime::Parser::Options->get_default();
    my $default_opts = Lib::GMime::Parser::Options::get_default();

Gets the default parser options.

=head2 C<get_address_compliance_mode()>

    my $compliance_mode = $parser_opts->get_address_compliance_mode();

Gets the compliance mode that should be used when parsing rfc822 addresses.

Note: Even in C<RFC_COMPLIANCE_STRICT> mode, the address parser is fairly
liberal in what it accepts. Setting it to C<RFC_COMPLIANCE_LOOSE> just
makes it try harder to deal with garbage input.

=head2 C<set_address_compliance_mode($string)>

    # set to strict compliance mode (default)
    $parser_opts->set_address_compliance_mode('RFC_COMPLIANCE_STRICT');

    # set to loose compliance mode
    $parser_opts->set_address_compliance_mode('RFC_COMPLIANCE_LOOSE');

Sets the compliance mode that should be used when parsing rfc822 addresses.

In general, you'll probably want this value to be C<RFC_COMPLIANCE_LOOSE>
(the default) as it allows maximum interoperability with existing (broken)
mail clients and other mail software such as sloppily written perl scripts
(aka spambots).

Note: Even in C<RFC_COMPLIANCE_STRICT> mode, the address parser is fairly
liberal in what it accepts. Setting it to C<RFC_COMPLIANCE_LOOSE> just makes
it try harder to deal with garbage input.

=head2 C<get_allow_addresses_without_domain()>

    my $allowed = $parser_opts->get_allow_addresses_without_domain();

Gets whether or not the rfc822 address parser should allow addresses
without a domain.

In general, you'll probably want this value to be FALSE (the default) as
it allows maximum interoperability with existing (broken) mail clients and
other mail software such as sloppily written perl scripts (aka spambots)
that do not properly quote the name when it contains a comma.

This option exists in order to allow parsing of mailbox addresses that do not
have a domain component. These types of addresses are rare and were typically
only used when sending mail to other users on the same UNIX system.

=head2 C<set_allow_addresses_without_domain($bool)>

    $parser_opts->set_allow_addresses_without_domain(1);

Sets whether the rfc822 address parser should allow addresses without a domain.

In general, you'll probably want this value to be FALSE (the default) as
it allows maximum interoperability with existing (broken) mail clients and
other mail software such as sloppily written perl scripts (aka spambots)
that do not properly quote the name when it contains a comma.

This option exists in order to allow parsing of mailbox addresses that
do not have a domain component. These types of addresses are rare and
were typically only used when sending mail to other users on the same
UNIX system.

=head2 C<get_parameter_compliance_mode()>

    my $mode = $parser_opts->get_parameter_compliance_mode();

Gets the compliance mode that should be used when parsing Content-Type
and Content-Disposition parameters.

Note: Even in C<RFC_COMPLIANCE_STRICT> mode, the parameter parser is
fairly liberal in what it accepts. Setting it to
C<RFC_COMPLIANCE_LOOSE> just makes it try harder to deal with
garbage input.

=head2 C<set_parameter_compliance_mode($string)>

    $parser_opts->set_parameter_compliance_mode($mode);

Sets the compliance mode that should be used when parsing Content-Type
and Content-Disposition parameters.

In general, you'll probably want this value to be
C<RFC_COMPLIANCE_LOOSE> (the default) as it allows maximum
interoperability with existing (broken) mail clients and other mail
software such as sloppily written perl scripts (aka spambots).

Note: Even in C<RFC_COMPLIANCE_STRICT> mode, the parameter parser is
fairly liberal in what it accepts. Setting it to
C<RFC_COMPLIANCE_LOOSE> just makes it try harder to deal with
garbage input.

=head2 C<get_rfc2047_compliance_mode()>

    my $mode = $parser_opts->get_rfc2047_compliance_mode();

Gets the compliance mode that should be used when parsing rfc2047 encoded words.

Note: Even in C<RFC_COMPLIANCE_STRICT> mode, the rfc2047 parser is
fairly liberal in what it accepts. Setting it to
C<RFC_COMPLIANCE_LOOSE> just makes it try harder to deal with
garbage input.

=head2 C<set_rfc2047_compliance_mode()>

    $parser_opts->set_rfc2047_compliance_mode($mode);

Sets the compliance mode that should be used when parsing rfc2047
encoded words.

In general, you'll probably want this value to be
C<RFC_COMPLIANCE_LOOSE> (the default) as it allows maximum
interoperability with existing (broken) mail clients and other mail
software such as sloppily written perl scripts (aka spambots).

Note: Even in C<RFC_COMPLIANCE_STRICT> mode, the parameter parser is
fairly liberal in what it accepts. Setting it to
C<RFC_COMPLIANCE_LOOSE> just makes it try harder to deal with
garbage input.

=head2 C<get_fallback_charsets()>

    my $charsets = $parser_opts->get_fallback_charsets();

Gets the fallback charsets to try when decoding 8-bit headers.

=head2 C<set_fallback_charsets(@strings)>

    $parser_opts->set_fallback_charsets($charsets);

Sets the fallback charsets to try when decoding 8-bit headers.

Note: It is recommended that the list of charsets start with utf-8 and
end with iso-8859-1.

=head2 C<get_warning_callback()>

TODO Not implemented yet.

=head2 C<set_warning_callback()>

TODO Not implemented yet.

