# Identify ICD9CM codes for the UMLS CUIs identified from processing
# MEDLINE dietary supplement subset and retain those that belong to
# the category: 219-319

function icd_mapping(db, cui, i)
    while i<= 5
        res = mysql_execute(db, "select distinct cui2 from mrrel where cui1 = \"$cui\" and rela = \"isa\";")
        if length(res[1]) != 0
            for r = 1:length(res[1])
                res1 = mysql_execute(db, "select distinct code from mrconso where cui in (select cui2 from mrrel where cui1 = \"$(res[1][r])\") and sab = \"icd9cm\";")
                if length(res1[1]) != 0
                    icd = res1[1][1]
                    return icd
                else
                    icd_mapping(db, res[1][r], i+1)
                end
            end
        end
        #println(i)
        i += 1
    end
end


using MySQL

db = mysql_connect("localhost","root","","umls")

#umls_cui = "C1317977"
#umls_cui = "C1299581"
#C1299581
#i = 1
#icd = icd_mapping(db, umls_cui, i)
#println(icd)


mimicICD  = open("./mimic/mimic_icd9_ccs_desc.txt")
mimic_icd = Dict{Any,Any}()
for ln in eachline(mimicICD)
  ln = chomp(ln)
  mimic_icd["$(split(ln, "\$")[1])"] = "$(join(split(ln, "\$")[2:3], "\$"))"
end


ouFile = open("./pubmed/filtered_medline_cui-icd_mmout.txt","w")
inFile = open("./pubmed/medline_cui_mmout.txt")

for ln in eachline(inFile)
    ln       = chomp(ln)
    pmid     = split(ln, "\$")[1]
    mscr     = split(ln, "\$")[2]
    umls_cui = split(ln, "\$")[3]
    #umls_cui = "C1317977"
    #println(umls_cui)
    iter = 1
    icd = icd_mapping(db, umls_cui, iter)
    #println(icd)

    if icd != nothing
        icd = string(icd)
        if ismatch(r"^[0-9]+$", icd) || ismatch(r"^[0-9]+\.[0-9]+$", icd)
            if parse(Float64, icd) >= 219.0 && parse(Float64, icd) <= 319.0
                icd    =  replace(icd, "\.", "")
                icd9cm = get(mimic_icd, "$icd", 0)
                if icd9cm != 0
                    println("$pmid\$$mscr\$$umls_cui\$$icd\$$icd9cm")
                    write(ouFile,"$pmid\$$mscr\$$umls_cui\$$icd\$$icd9cm\n")
                end
            end
        end
    end
end

close(ouFile)
mysql_disconnect(db)
