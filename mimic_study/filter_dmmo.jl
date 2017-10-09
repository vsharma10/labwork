# Filter mhealth_ds-sub-icd9_mmout.txt to retain only entries that belong to
# the list of ICD-9-CM codes identified from MIMIC data.
# Aug 21, 2017

mimicICD  = open("mimic_icd9_ccs_desc.txt")
mimic_icd = Dict{Any,Any}()

for ln in eachline(mimicICD)
  ln = chomp(ln)
  mimic_icd["$(split(ln, "\$")[1])"] = "$(join(split(ln, "\$")[2:3], "\$"))"
end

#println(mimic_icd)

using MySQL

umls_db = mysql_connect("localhost","root","","umls")

outFile = open("./pubmed/parsed_mmout/filtered_medline_icd9_mmout.txt","w")
inFile  = open("./pubmed/parsed_mmout/medline_icd9_mmout.txt")

for ln in eachline(inFile)
  ln  = chomp(ln)
  cui = split(ln, "\$")[3]
  res = mysql_execute(umls_db, "select distinct code from mrconso where cui = \"$cui\" and sab = \"icd9cm\";")
  for i = 1:length(res[1])
    code   = res[1][i]
    code   = replace(code, "\.", "")
    icd9cm = get(mimic_icd, "$code", 0)
    if icd9cm != 0
      println("$ln\$$code\$$icd9cm")
      write(outFile, "$ln\$$code\$$icd9cm\n")
      break
    end
  end
end

mysql_disconnect(umls_db)
close(outFile)
