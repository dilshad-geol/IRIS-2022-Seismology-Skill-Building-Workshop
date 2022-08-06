#
# Script to produce focal mechanism solution and plot from SAC first motions
#

## Key Variables
set numpolerr=0 # Number of Polarity Errors Allowed in the Solution

if (${#argv}<1) then 
  echo "usage: focmec.csh [SAC files]"
  echo "  example: focmec.csh *HZ*SAC"
  exit
endif

## Create FOCMEC Input from SAC Files
echo -n "" >! focmec.inp
saclst ka az evdp dist f $* | awk '$2!=-12345{split($1,s,"."); if (length(s[2])==5) s[2]=substr(s[2],2);p=substr($2,3,1); printf "%4s %7.3f %7.3f %7.3f %s\n",s[2],$(NF-2),$(NF-1),$NF,p}' >! focmec.list
foreach depdist ("`cat focmec.list`")
  set dep=`echo $depdist | awk '{print $3}'`
  set dist=`echo $depdist | awk '{print $4}'`
#  set toa=`awk 'NR>1{d=sqrt(($1-x)^2+($2-y)^2); print $0,d}' x=$dep y=$dist /home/jovyan/iris_data/SSBWFiles/toa.xyz | sort -k 5 -n | awk '{if (NR==1) s=$3;if ($3<s) s=$3;if (NR==5) {printf "%07.3f", s;exit}}'`
   set toa=`awk 'NR>1{d=sqrt(($1-x)^2+($2-y)^2); print $0,d}' x=$dep y=$dist /home/jovyan/iris_data/SSBWFiles/toa.xyz | sort -k 5 -n | awk '{s+=$3;n++;if (NR==5) {printf "%07.3f", s/n;exit}}'`
  echo $depdist $toa | awk '{printf "%4s %07.3f %07.3f%s\n",$1,$2,$6,$5}' >> focmec.inp
end
sort -k 2 -n focmec.inp >! focmec.tmp
\mv focmec.tmp focmec.inp
set title=`saclst kztime f *SAC | awk 'NF>5{printf "%4d-%03d %02d:%02d:%02d\n",$2,$3,$4,$5,$6;exit}'`

## FOCMEC Parameters
echo "focmec.out" >! focmec.stdin # Output file name (for plotting) [focmec.out]
echo "title" >> focmec.stdin # Comment - up to 80 characters
echo "focmec.inp" >> focmec.stdin # Input filespec
echo "Y" >> focmec.stdin # Correct file?...[Y]
echo "N" >> focmec.stdin # Want relative weighting?..[N]
echo "$numpolerr" >> focmec.stdin # Allowed P polarity errors..[0]
echo "100" >> focmec.stdin # Exit after this many acceptable sols...[100]
echo "0" >> focmec.stdin # Minimum search value B trend..[0]
echo "5" >> focmec.stdin # Increment for B trend..[5 degrees]
echo "355" >> focmec.stdin # Maximum B trend..[355 degrees]
echo "0" >> focmec.stdin # Minimum search value B plunge..[0]
echo "5" >> focmec.stdin # Increment for B plunge..[5 degrees]
echo "90" >> focmec.stdin # Maximum B plunge..[90 degrees]
echo "0" >> focmec.stdin # Minimum search value A angle..[0]
echo "5" >> focmec.stdin # Increment for A angle..[5 degrees]
echo "85" >> focmec.stdin # Maximum A angle..[85 degrees]

alias focmec /home/jovyan/focmec/bin/focmec
focmec < focmec.stdin

## FOCPLT Parameters
echo "N" >! focplt.stdin # Upper hemisphere projection?..[N]
echo "Y" >> focplt.stdin # Plot polarities and/or ratio data?..[Y]
echo "focmec.inp" >> focplt.stdin # Enter input file name..[focmec.inp]
echo "Y" >> focplt.stdin # Desired file?..[Y]
echo "Y" >> focplt.stdin # Plot impulsive P polarities?..[Y]
echo "0.25" >> focplt.stdin # Enter size for impulsive P polarities [0.25]
echo "1" >> focplt.stdin # linewidth for impulsive P polarities..[1]
echo "3" >> focplt.stdin # Enter JPLOT from among 1,2,3,4,6..[3]
echo "2" >> focplt.stdin # linewidth for circle outline..[2]
echo "Y" >> focplt.stdin # Add a title?..[Y]
echo "$title #PolarityError=$numpolerr" >> focplt.stdin # Enter title - up to 40 characters..[]
echo "2" >> focplt.stdin # linewidth for title..[2]
echo "Y" >> focplt.stdin # Include time & file name?..[Y]
echo "1" >> focplt.stdin # Enter linewidth value..[1]
echo "N" >> focplt.stdin # Add more data to plot?..[N]
echo "Y" >> focplt.stdin # Plot focal mechanism solutions?..[Y]
echo "N" >> focplt.stdin # Print/display solution summaries?..[N]
echo "N" >> focplt.stdin # Plot P, T and B axes? [Y]
echo "Y" >> focplt.stdin # P nodal planes..[Y]
echo "N" >> focplt.stdin # Dashed line?..[N]
echo "1" >> focplt.stdin # Enter linewidth for solutions..[1]
echo "Y" >> focplt.stdin # Solutions on same plot as data?..[Y]
echo "Y" >> focplt.stdin # Input solutions from a file?..[Y]
echo "focmec.out" >> focplt.stdin # Input file name..[focmec.out]
echo "Y" >> focplt.stdin # Correct file? [Y]
echo "Y" >> focplt.stdin # Plot time & file name?..[Y]
echo "1" >> focplt.stdin # Enter linewidth..[1]
echo "N" >> focplt.stdin # Add more solutions to same plot?..[N]
echo "N" >> focplt.stdin # Add a plot label?..[N]
echo "0" >> focplt.stdin # Wait for N seconds before proceding..[N=5]

alias focplt /home/jovyan/focmec/bin/focplt
focplt < focplt.stdin

sgftops temp.sgf focplt.ps
# gv -landscape focplt.ps &

### Create a plot of the focal mechanism solutions with GMT
set psfile=plot.focmec.ps
set xs=6.5
echo 0 0 | gmt psxy -R-1/1/-1/1 -JX$xs -X1 -Y2.75 -K -P >! $psfile
awk 'NF==6&&$6==0.0{print 0,0,0,$2,$1,$3,5,0,0}' focmec.out >! focmec.meca
set nsol=`wc -l < focmec.meca`
awk 'NR==int(n/2)' n=$nsol focmec.meca | gmt psmeca -R-1/1/-1/1 -JX$xs -K -O -Sa$xs -G160 >> $psfile
gmt psmeca focmec.meca -R-1/1/-1/1 -JX$xs -K -O -Sa$xs -L2 -T0 >> $psfile
gmt psbasemap -JA0/0/$xs -Rd -B1:1 -K -O >> $psfile

### Add the station polarity information
 awk 'NR>1{n=$1; st=$2; d=substr($3,1,7)*1; p=substr($3,8,1); c=1; if (p=="U") c=-1; if (d>90) {d=180-d;st-=180} print st,d,c,n}' focmec.inp | awk '{dtr=3.14/180;r=sin($2*dtr)*sqrt(1/(1+cos($2*dtr))); o=(90-$1)*dtr; print r*cos(o),r*sin(o),$3,$4}' >! plot.focmec.sta 
awk '$3==1' plot.focmec.sta | gmt psxy -R-1/1/-1/1 -JX$xs -K -O -Si.35 -W1,255/0/0 -N >> $psfile
awk '$3==-1' plot.focmec.sta | gmt psxy -R-1/1/-1/1 -JX$xs -K -O -St.35 -W1,0/0/255 -N >> $psfile
awk '$3==1{print $1,$2,7,0,0,6,$4}' plot.focmec.sta | gmt pstext -R-1/1/-1/1 -JX$xs -K -O -N >> $psfile
awk '$3==-1{print $1,$2,7,0,0,6,$4}' plot.focmec.sta | gmt pstext -R-1/1/-1/1 -JX$xs -K -O -N >> $psfile

echo 0 0 | gmt psxy -R-1/1/-1/1 -JX$xs -O >> $psfile
gv $psfile &
