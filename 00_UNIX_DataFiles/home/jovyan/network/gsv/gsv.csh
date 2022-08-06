#!/bin/csh

foreach sta ( SDV SDCO PTGA SACV TRQA KDAK KIEV )

	FetchData -S $sta -C "BHZ" -L 00 -s 2010-01-12T21:53:10.4 -e 30M -o gsv.mseed -m gsv.meta
	mseed2sac gsv.mseed -m gsv.meta -E 2010,012,21:53:10/18.3823/-72.588/15

end
