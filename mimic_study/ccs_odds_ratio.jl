# Calculate odds ratio and confidencde intervals for DS subset data for
# MIMIC study
# For CCS category codes
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

entries_res = mysql_execute(db, "select distinct a.string, b.ccs from medline_inf_nhp as a inner join medline_inf_icd9 as b on a.pmid = b.pmid;")
#outFile = open("nhp_ccs-cat_odds-ratio_5.txt","w")
outFile = open("medline_nhp_ccs-cat_odds-ratio_inf.txt","w")

for i = 1:length(entries_res[1])
  dsupp = entries_res[1][i]
  ccs = entries_res[2][i]
  a  = mysql_execute(db, "select count(distinct a.pmid) from medline_inf_nhp as a inner join medline_inf_icd9 as b on a.pmid = b.pmid where a.string = \"$dsupp\" and b.ccs = \"$ccs\";")[1][1]
  b  = mysql_execute(db, "select count(distinct a.pmid) from medline_inf_nhp as a inner join medline_inf_icd9 as b on a.pmid = b.pmid where a.string = \"$dsupp\" and b.ccs != \"$ccs\";")[1][1]
  c  = mysql_execute(db, "select count(distinct a.pmid) from medline_inf_nhp as a inner join medline_inf_icd9 as b on a.pmid = b.pmid where a.string != \"$dsupp\" and b.ccs = \"$ccs\";")[1][1]
  d  = mysql_execute(db, "select count(distinct a.pmid) from medline_inf_nhp as a inner join medline_inf_icd9 as b on a.pmid = b.pmid where a.string != \"$dsupp\" and b.ccs != \"$ccs\";")[1][1]

  if a >= 5 && b >= 5 && c >= 5 && d >= 5
      or, lci, uci = calc_odds_ratio(a,b,c,d)
      if or > 1 && lci > 1 && a >= 5
          println("$dsupp\$$ccs\$$or\$$lci\$$uci")
          write(outFile, "$dsupp\$$ccs\$$or\$$lci\$$uci\n")
      end
  end
end

mysql_disconnect(db)
close(outFile)
