#! /bin/sh

# Print the modification date of $1 `nicely'.

(date; ls -l $1) | awk '
BEGIN {
	full["Jan"] = "January"; number["Jan"] = 1;
	full["Feb"] = "February"; number["Feb"] = 2;
	full["Mar"] = "March"; number["Mar"] = 3;
	full["Apr"] = "April"; number["Apr"] = 4;
	full["May"] = "May"; number["May"] = 5;
	full["Jun"] = "June"; number["Jun"] = 6;
	full["Jul"] = "July"; number["Jul"] = 7;
	full["Aug"] = "August"; number["Aug"] = 8;
	full["Sep"] = "September"; number["Sep"] = 9;
	full["Oct"] = "October"; number["Oct"] = 10;
	full["Nov"] = "November"; number["Nov"] = 11;
	full["Dec"] = "December"; number["Dec"] = 12;
}

NR == 1 {
	month = $2;
	year = $6;
}

NR == 2 {
	if ($8 ~ /:/) {
		if (number[$6] > number[month])
			year--;
	}
	else
		year = $8;
	print $7, full[$6], year
}'
