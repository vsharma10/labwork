# Identify ICD9CM codes for the UMLS CUIs identified from processing
# MEDLINE dietary supplement subset and retain those that belong to
# the category: 219-319

function icd_mapping(db, cui, i)
    while i <= 5
        println(i)
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
umls_cui = "C1299581"
#C1299581
i = 1
icd = icd_mapping(db, umls_cui, i)
println(icd)

mysql_disconnect(db)
