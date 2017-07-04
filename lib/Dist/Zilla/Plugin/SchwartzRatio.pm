package Dist::Zilla::Plugin::SchwartzRatio;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: display the Schwartz ratio of the distribution upon release
$Dist::Zilla::Plugin::SchwartzRatio::VERSION = '0.3.0';

use 5.22.0;
use warnings;

use List::UtilsBy qw/ sort_by /;
use MetaCPAN::Client;

use Moose;

with qw/
    Dist::Zilla::Role::Plugin
    Dist::Zilla::Role::AfterRelease
/;

use experimental 'signatures';

has mcpan => (
    is      => 'ro',
    lazy    => 1,
    default => sub { MetaCPAN::Client->new },
);

has releases => (
    is => 'ro',
    traits => [ 'Array' ],
    handles => {
        all_releases => 'elements',
        nbr_releases => 'count',
    },
    lazy => 1,
    default => sub($self) {
        
        my $releases = $self->mcpan->release({
            distribution => $self->zilla->name
        });
        my @releases;

        while( my $r = $releases->next ) {
            my( $version, $date ) = map { $r->$_ } qw/ version date /;
            $date =~ s/T.*//;
            push @releases, [ 'v'.$version, $date ];
        }

        return [ sort_by { $_->[1] } @releases ];
    },
);

sub after_release($self,@) {

    $self->log( $self->nbr_releases . " old releases are lingering on CPAN" );
    $self->log( "\t" . join ', ', @$_ ) for $self->all_releases;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Plugin::SchwartzRatio - display the Schwartz ratio of the distribution upon release

=head1 VERSION

version 0.3.0

=head1 SYNOPSIS

In dist.ini:

    [SchwartzRatio]

=head1 DESCRIPTION

The Schwartz Ratio of CPAN is the number of number of latest
releases over the total number of releases that CPAN has. For
a single distribution, it boils down to the less exciting
number of previous releases still on CPAN. 

After a successful release, the plugin displays
the releases of the distribution still kicking around on CPAN,
just to give an idea to the author that maybe it's time
to do some cleanup.

=head1 SEE ALSO

=over

=item L<App-PAUSE-cleanup|https://metacpan.org/release/App-PAUSE-cleanup> 

CLI utility to list and help you delete easily your distributions on CPAN.

=back

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
