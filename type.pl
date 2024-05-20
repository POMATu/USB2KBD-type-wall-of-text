#!/bin/env perl

use strict;
#use warnings;
use Device::SerialPort; #sudo apt install libdevice-serialport-perl
use Time::HiRes qw(usleep);
use feature 'switch'; # perl > 5.10
use utf8;
#use Encode qw( decode_utf8 );
#use Data::Dumper;
no if $] >= 5.018, warnings => "experimental";

binmode(STDIN, ":utf8");

our $device_id = 4723;
our $port_name = '/dev/ttyACM0'; # Replace with your COM port name
our $delay = 20; # milliseconds
our $init_delay = 300;

# Initialize the serial port
our $port = Device::SerialPort->new($port_name) or die "Can't open $port_name: $!";

# Configure the serial port
$port->baudrate(9600);           # Set the baud rate to 9600
$port->parity("none");           # No parity
$port->databits(8);              # 8 data bits
$port->stopbits(1);              # 1 stop bit
$port->handshake("none");        # No handshaking


my $input = do { local $/; <> };

my $input2 = $input;
chomp($input); # we dont want it to end with \n if its just one line to avoid executing command
if ($input =~ /.*\n.*/) {
	$input = $input2; # nah it is wall of text so restoring original value
}

print "Read input:\n";
print $input;
print "\n";

sendTTY(""); # sending \n first just in case there is some crap pretyped
sendTTY(cmdReleaseAll()); # releasing also just in case
usleep($init_delay*1000); # needed to unfuck X server input to window activation otherwise it swallows first symbol

for my $event (convertChar($input)) {

	print "Executing event: " . $event . "\n";

	if ($event > 0) {
		sendTTY(cmdSendKey($event));
		#print cmdSendKey($event);
		usleep($delay*1000);
		sendTTY(cmdReleaseAll()); 
		next;
	}

	# others need modifier
	sendTTY(cmdSendKey(225)); # left shift
	sendTTY(cmdSendKey(-1 * $event));
	#print cmdSendKey(-1 * $event);

	usleep($delay*1000);
	sendTTY(cmdReleaseAll()); 

}

#print "Sending payload:";
#print $c;
#print "\n";
#sendTTY($c);

sub cmdSendKey {
	my $cmd = shift;
	return id() . b1("press") . b2($cmd) . b3() . b4();
}

sub cmdReleaseKey {
	my $cmd = shift;
	return id() . b1("release") . b2($cmd) . b3() . b4();
}

sub cmdReleaseAll {
	return id() . b1("releaseall") . b2(0) . b3() . b4();
}


sub b1 {
	my $cmd = shift;
	given ($cmd) {
	    when ('press') {
	       return 1;
	    }
	    when ('release') {
	        return 2;
	    }
	    when ('mouse') {
	        return 4;
	    }
	    when ('wheelup') {
	        return 6;
	    }
	    when ('wheeldown') {
	        return 7;
	    }
	    when ('releaseall') {
	        return 8;
	    }
	    default {
	        return 0;
	    }
	}

}

sub b2 {
	my $cmd = shift;
	return sprintf("%03d", $cmd);
}

sub b3 {
	return sprintf("%05d", 0);
}

sub b4 {
	return b3;
}

sub id {
	return $device_id;
}

sub sendTTY {
my $message = shift;

# Write the message to the COM port
$port->write($message . "\n") or die "Failed to write to $port_name: $!";

print "Sent message successfully: " . $message . "\n";

# Flush the write buffer
$port->write_drain or warn "Failed to flush write buffer: $!";

#print "Message sent successfully to $port_name\n";
}

sub convertChar {

my %charsany = (
'1' => '30',
'2' => '31',
'3' => '32',
'4' => '33',
'5' => '34',
'6' => '35',
'7' => '36',
'8' => '37',
'9' => '38',
'0' => '39',
"\n" => '40',
"\t" => '43',
" " => '44',
#'-' => '45',
'=' => '46',
#extra keypad override for better multi-layout stability
'/' => "84",
'*' => "85",
'-' => "86",
'+' => "87",
# extra remapping of soy utf8 shit
"—" => "86",
);

my %charslc = (
'a' => '4',
'b' => '5',
'c' => '6',
'd' => '7',
'e' => '8',
'f' => '9',
'g' => '10',
'h' => '11',
'i' => '12',
'j' => '13',
'k' => '14',
'l' => '15',
'm' => '16',
'n' => '17',
'o' => '18',
'p' => '19',
'q' => '20',
'r' => '21',
's' => '22',
't' => '23',
'u' => '24',
'v' => '25',
'w' => '26',
'x' => '27',
'y' => '28',
'z' => '29',
'[' => '47',
']' => '48',
"\\" => '49',
';' => '51',
"'" => '52',
'`' => '53',
',' => '54',
'.' => '55',
'/' => '56',
);

my %charsuc = (
'A' => '4',
'B' => '5',
'C' => '6',
'D' => '7',
'E' => '8',
'F' => '9',
'G' => '10',
'H' => '11',
'I' => '12',
'J' => '13',
'K' => '14',
'L' => '15',
'M' => '16',
'N' => '17',
'O' => '18',
'P' => '19',
'Q' => '20',
'R' => '21',
'S' => '22',
'T' => '23',
'U' => '24',
'V' => '25',
'W' => '26',
'X' => '27',
'Y' => '28',
'Z' => '29',
'!' => '30',
'@' => '31',
'#' => '32',
'$' => '33',
'%' => '34',
'^' => '35',
'&' => '36',
'*' => '37',
'(' => '38',
')' => '39',
'_' => '45',
'+' => '46',
'{' => '47',
'}' => '48',
'|' => '49',
':' => '51',
'"' => '52',
'~' => '53',
'<' => '54',
'>' => '55',
'?' => '56',
# extra remapping soy utf8 shit
"«" => "52",
"»" => "52",
);

#extra bonus: Cyrillic typing with йцукен keyboard (you are responsible for selecting right layout beforehand tho)
my %cyrcharslc = (
'ф' => '4',
'и' => '5',
'с' => '6',
'в' => '7',
'у' => '8',
'а' => '9',
'п' => '10',
'р' => '11',
'ш' => '12',
'о' => '13',
'л' => '14',
'д' => '15',
'ь' => '16',
'т' => '17',
'щ' => '18',
'з' => '19',
'й' => '20',
'к' => '21',
'ы' => '22',
'е' => '23',
'г' => '24',
'м' => '25',
'ц' => '26',
'ч' => '27',
'н' => '28',
'я' => '29',
'-' => '45',
'=' => '46',
'х' => '47',
'ъ' => '48',
"\\" => '49',
'ж' => '51',
"э" => '52',
'ё' => '53',
'б' => '54',
'ю' => '55',
'.' => '56',
);

my %cyrcharsuc = (
'Ф' => '4',
'И' => '5',
'С' => '6',
'В' => '7',
'У' => '8',
'А' => '9',
'П' => '10',
'Р' => '11',
'Щ' => '12',
'О' => '13',
'Л' => '14',
'Д' => '15',
'Ь' => '16',
'Т' => '17',
'Щ' => '18',
'З' => '19',
'Й' => '20',
'К' => '21',
'Ы' => '22',
'Е' => '23',
'Г' => '24',
'М' => '25',
'Ц' => '26',
'Ч' => '27',
'Н' => '28',
'Я' => '29',
'!' => '30',
'"' => '31',
'№' => '32',
';' => '33',
'%' => '34',
':' => '35',
'?' => '36',
'*' => '37',
'(' => '38',
')' => '39',
'_' => '45',
'+' => '46',
'Х' => '47',
'Ъ' => '48',
"/" => '49',
'Ж' => '51',
"Э" => '52',
'Ё' => '53',
'Б' => '54',
'Ю' => '55',
',' => '56',
# extra remapping of soy utf8 shit
"«" => "31",
"»" => "31",
#extra remapping of unavailable characters to simillar ones your probably wont need this so you can delete stuff below
'[' => '38',
']' => '39',
'{' => '38',
'}' => '39',
"'" => '31',
'|' => '49',
);

my $text = shift;

# detect keyboard layout
my $is_cyrillic = has_cyrillic($text);

if ($is_cyrillic) {
	print "Cyrillic mode\n";
} else {
	print "Latin mode\n";
}

my @result = ();

for my $char (split //, $text) {
   
	my $tres;
	$tres = $charsany{$char}; # layout independant
	if (defined $tres) {
		push @result, $tres;
		next;
	}

	if (!$is_cyrillic) {
		$tres = $charslc{$char};
		if (defined $tres) {
			push @result, $tres;
			next;
		}
		$tres = $charsuc{$char};
		if (defined $tres) {
			if (defined $tres) {
				push @result, "-" . $tres;
				next;
			}
		}
	} else {
		$tres = $cyrcharslc{$char};
		if (defined $tres) {
			push @result, $tres;
			next;
		}
		$tres = $cyrcharsuc{$char};
		if (defined $tres) {
			if (defined $tres) {
				push @result, "-" . $tres;
				next;
			}
		}
	}
}

return @result;
}


# Function to check if a string is a digit
sub is_digit {
    my ($str) = @_;
    return $str =~ /^\d+$/;
}

# Function to check if a string has any Cyrillic characters
sub has_cyrillic {
    my ($string) = @_;
    
    #$string = decode_utf8($string);
    my $res = $string =~ /.*[А-Яа-яЁё].*/;
    print $res . ":" . $string . "\n";
    return $res;
}


# Clean up and close the port
$port->close or warn "Failed to close $port_name: $!";