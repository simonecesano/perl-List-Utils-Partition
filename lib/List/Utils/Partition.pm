use strict;
use warnings;
package List::Utils::Partition;

# ABSTRACT: splits lists based on functions

use Exporter 'import';
our @EXPORT_OK = qw(partition segment);  # symbols to export on request

use Want;

sub partition(&@) {
    my $cb = shift;
    my @input = @_;
    my %ret;

    for (@input) {
	my $k = $cb->($_);
	$ret{$k} = [] unless $ret{$k};
	push $ret{$k}->@*, $_;
    }
    if (want('ARRAY')) {
	rreturn values %ret
    }
    elsif (want('HASH')) {
	rreturn \%ret;
    }
    return values %ret;
}

sub segment(&@) {
    my $cb = shift;
    my @input = @_;

    my @retval = [];

    my $pkg = caller;
    my $max = $#input;

    for my $i (0 .. $max) {
        push @{$retval[$#retval]}, $input[$i];
        no strict 'refs';
        local *{"${pkg}::a"} = \$input[$i];
        local *{"${pkg}::b"} = \$input[$i + 1]; # autovivification!
        if (($i < $max) && $cb->()) {
            push @retval, [];
        }
    }
    pop @retval unless @{$retval[$#retval]};
    return @retval;
}

1;
