set datafile separator ","
set term pngcairo size 1200,1500
set output "cylinder_flow_2D_plot.png"

unset key
set view map
set pm3d map
set tics out
set border lw 1
set size ratio -1

set multiplot layout 3,1 rowsfirst

# margins: leave room for y-tics labels + colorbox
set lmargin 8
set rmargin 8
set tmargin 1
set bmargin 1

tcmd(f) = sprintf("awk -F',' '{line=$0; sub(/,+$/,\"\",line); nf=split(line,a,\",\"); for(i=1;i<=nf;i++) A[NR,i]=a[i]; if(nf>max) max=nf} END{for(i=1;i<=max;i++){for(j=1;j<=NR;j++){printf \"%%s%%s\", A[j,i], (j<NR?\",\":\"\")} printf \"\\n\"}}' %s", f)

set xrange [0:482]
set yrange [0:122]

set title "U"
plot "< ".tcmd("U_final.csv") matrix with image

set title "V"
plot "< ".tcmd("V_final.csv") matrix with image

set title "p"
plot "< ".tcmd("p_final.csv") matrix with image

unset multiplot
set output
