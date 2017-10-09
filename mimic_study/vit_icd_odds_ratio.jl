# Calculate odds ratio and confidencde intervals for DS subset data for
# MIMIC study
# Specific for Vitamins
# August 23, 2017

"""
a = Exposure: Yes and Event: Yes
b = Exposure: Yes and Event: No
c = Exposure: No  and Event: Yes
d = Exposure: No  and Event: No
"""

function calc_odds_ratio(a::Int64, b::Int64, c::Int64, d::Int64)
  odds_ratio = round((a*d)/(b*c), 2)
  uci        = round(exp(log(odds_ratio) + 1.96*sqrt((1/a) + (1/b) + (1/c) + (1/d))), 2)
  lci        = round(exp(log(odds_ratio) - 1.96*sqrt((1/a) + (1/b) + (1/c) + (1/d))), 2)
  return odds_ratio, lci, uci
end


using MySQL

db = mysql_connect("localhost","root","","mimic_study")

vit_strings = ["vit\%","vit\%d\%","vit\%a\%","vit\%c\%","vit\%e\%","vit\%k\%","vit\%u\%","vit\%b\%1","vit\%b\%12","vit\%b\%6","vit\%b\%"]

entries_res = mysql_execute(db, "select distinct a.string, b.icd9 from medline_nhp as a inner join medline_icd9 as b on a.pmid = b.pmid where a.string like \"vit\%\";")
#entries_res = mysql_execute(db, "select distinct b.ccs from medline_nhp as a inner join medline_icd9 as b on a.pmid = b.pmid where a.string like \"vit\%\";")
#println(entries_res)
#outFile = open("nhp_icd_odds-ratio.txt","w")

for i = 1:length(entries_res[1])
  dsupp = entries_res[1][i]
  icd   = entries_res[2][i]
  #ccs = "660"
  #println(icd)
  for str in vit_strings
    #a  = mysql_execute(db, "select count(distinct a.pmid) from medline_nhp as a inner join medline_icd9 as b on a.pmid = b.pmid where a.string = \"$dsupp\" and b.icd9 = \"$icd\";")[1][1]
    a  = mysql_execute(db, "select count(distinct a.pmid) from medline_nhp as a inner join medline_icd9 as b on a.pmid = b.pmid where a.string like \"$str\" and b.icd9 = \"$icd\";")[1][1]
    #println(a)
    #b  = mysql_execute(db, "select count(distinct a.pmid) from medline_nhp as a inner join medline_icd9 as b on a.pmid = b.pmid where a.string = \"$dsupp\" and b.icd9 != \"$icd\";")[1][1]
    b  = mysql_execute(db, "select count(distinct a.pmid) from medline_nhp as a inner join medline_icd9 as b on a.pmid = b.pmid where a.string like \"$str\" and b.icd9 != \"$icd\";")[1][1]
    #println(b)
    #c  = mysql_execute(db, "select count(distinct a.pmid) from medline_nhp as a inner join medline_icd9 as b on a.pmid = b.pmid where a.string != \"$dsupp\" and b.icd9 = \"$icd\";")[1][1]
    c  = mysql_execute(db, "select count(distinct a.pmid) from medline_nhp as a inner join medline_icd9 as b on a.pmid = b.pmid where a.string not like \"$str\" and b.icd9 = \"$icd\";")[1][1]
    #println(c)
    #d  = mysql_execute(db, "select count(distinct a.pmid) from medline_nhp as a inner join medline_icd9 as b on a.pmid = b.pmid where a.string != \"$dsupp\" and b.icd9 != \"$icd\";")[1][1]
    d  = mysql_execute(db, "select count(distinct a.pmid) from medline_nhp as a inner join medline_icd9 as b on a.pmid = b.pmid where a.string not like \"$str\" and b.icd9 != \"$icd\";")[1][1]
    #println(d)

    or, lci, uci = calc_odds_ratio(a,b,c,d)
    if or > 1 && lci > 1 && a >= 5
      println("$str\$$icd\$$or\$$lci\$$uci")
      #write(outFile, "$dsupp\$$icd\$$or\$$lci\$$uci\n")
    end
  end
end

mysql_disconnect(db)
#close(outFile)
