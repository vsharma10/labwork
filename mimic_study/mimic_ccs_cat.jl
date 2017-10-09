# Extract CCS category for ICD9 codes related to Mental Health Category

using MySQL

db = mysql_connect("localhost","root","","mimic_study")

ouFile = open("icd9_ccs_desc.txt","w")
inFile = open("mimic_mhealth_icd9.txt")

for ln in eachline(inFile)
  ln = chomp(ln)
  ln = strip(ln)
  res = mysql_execute(db, "select ccs_cat, ccs_desc from ccs_cat where icd9 = \"$ln\";")
  for i = 1:length(res[1])
    println("$ln\$$(res[1][i])\$$(res[2][i])")
    write(ouFile, "$ln\$$(res[1][i])\$$(res[2][i])\n")
  end
end

mysql_disconnect(db)
close(inFile)
close(ouFile)
