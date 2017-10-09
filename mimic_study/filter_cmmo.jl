# Filter medline_nhp_mmout.txt to retain only entries that belong to PMIDs
# containing ICD-9-CM codes identified from MIMIC data: (filtered_medline_nhp_mmout.txt).
# Aug 21, 2017

pmidFile   = open("./pubmed/filtered_medline_cui-icd_mmout.txt")
pmid_array = Any[]
for ln in eachline(pmidFile)
  ln   = chomp(ln)
  pmid = split(ln, "\$")[1]
  push!(pmid_array, pmid)
end
pmid_array = unique(pmid_array)
#println(pmid_array)
ouFile = open("./pubmed/filtered_medline_cui-nhp_mmout.txt","w")

inFile = open("./pubmed/icd9-direct/parsed_mmout/medline_nhp_mmout.txt")
for ln in eachline(inFile)
  ln   = chomp(ln)
  pmid = split(ln, "\$")[1]
  if in(pmid, pmid_array)
    println(ln)
    write(ouFile, "$ln\n")
  end
end

close(ouFile)
