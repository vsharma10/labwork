# Parse Single level CCS_2015 file: dxref-2015.csv

ouFile = open("DX-Ref-CCS.txt","w")
dxFile = open("./Single_Level_CCS_2015/dxref-2015.csv")

for ln in eachline(dxFile)
  ln       = chomp(ln)
  icd9     = split(ln, "\,")[1]
  icd9     = strip(icd9[2:(end-1)])
  ccs      = split(ln, "\,")[2]
  ccs_cat  = strip(ccs[2:(end-1)])
  ccs_des  = split(ln, "\,")[3]
  ccs_des  = strip(ccs_des[2:(end-1)])
  icd9_des = split(ln, "\,")[4]
  icd9_des  = strip(icd9_des[2:(end-1)])

  println("$icd9\$$ccs_cat\$$ccs_des\$$icd9_des")
  write(ouFile,"$icd9\$$ccs_cat\$$ccs_des\$$icd9_des\n")
end

close(dxFile)
close(ouFile)
