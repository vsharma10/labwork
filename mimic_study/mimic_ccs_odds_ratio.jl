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
  odds_ratio::Float64 = round((a*d)/(b*c), 2)
  uci::Float64        = round(exp(log(odds_ratio) + 1.96*sqrt((1/a) + (1/b) + (1/c) + (1/d))), 2)
  lci::Float64        = round(exp(log(odds_ratio) - 1.96*sqrt((1/a) + (1/b) + (1/c) + (1/d))), 2)
  return odds_ratio, lci, uci
end


using MySQL

db = mysql_connect("localhost","root","","mimic_study")

entries_res = mysql_execute(db, "select distinct a.nhp_string, b.ccs_cat from mimic_nhp as a inner join mimic_icd_ccs as b on a.sub_id = b.sub_id;")
#entries_res = mysql_execute(db, "select distinct b.ccs from medline_nhp as a inner join medline_icd9 as b on a.pmid = b.pmid where a.string like \"vit\%\";")
#println(entries_res)
outFile = open("mimic_nhp_ccs-cat_odds-ratio_5.txt","w")

for i = 1:length(entries_res[1])
  dsupp = entries_res[1][i]
  ccs = entries_res[2][i]
  #ccs = "660"
  #println(icd)
  println("\[$i\/$(length(entries_res[1]))\]")
  a  = mysql_execute(db, "select count(distinct a.sub_id) from mimic_nhp as a inner join mimic_icd_ccs as b on a.sub_id = b.sub_id where a.nhp_string = \"$dsupp\" and b.ccs_cat = \"$ccs\";")[1][1]
  #a  = mysql_execute(db, "select count(distinct a.pmid) from medline_nhp as a inner join medline_icd9 as b on a.pmid = b.pmid where a.string like \"vit\%b\%12\" and b.ccs = \"$ccs\";")[1][1]
  #println(a)
  b  = mysql_execute(db, "select count(distinct a.sub_id) from mimic_nhp as a inner join mimic_icd_ccs as b on a.sub_id = b.sub_id where a.nhp_string = \"$dsupp\" and b.ccs_cat != \"$ccs\";")[1][1]
  #b  = mysql_execute(db, "select count(distinct a.pmid) from medline_nhp as a inner join medline_icd9 as b on a.pmid = b.pmid where a.string like \"vit\%b\%12\" and b.ccs != \"$ccs\";")[1][1]
  #println(b)
  c  = mysql_execute(db, "select count(distinct a.sub_id) from mimic_nhp as a inner join mimic_icd_ccs as b on a.sub_id = b.sub_id where a.nhp_string != \"$dsupp\" and b.ccs_cat = \"$ccs\";")[1][1]
  #c  = mysql_execute(db, "select count(distinct a.pmid) from medline_nhp as a inner join medline_icd9 as b on a.pmid = b.pmid where a.string not like \"vit\%b\%12\" and b.ccs = \"$ccs\";")[1][1]
  #println(c)
  if a >= 5 && b >= 5 && c >= 5
      d  = mysql_execute(db, "select count(distinct a.sub_id) from mimic_nhp as a inner join mimic_icd_ccs as b on a.sub_id = b.sub_id where a.nhp_string != \"$dsupp\" and b.ccs_cat != \"$ccs\";")[1][1]
      #d  = mysql_execute(db, "select count(distinct a.pmid) from medline_nhp as a inner join medline_icd9 as b on a.pmid = b.pmid where a.string not like \"vit\%b\%12\" and b.ccs != \"$ccs\";")[1][1]
      #println(d)
      #if a >= 5 && b >= 5 && c >= 5 && d >= 5
      if d >= 5
          or, lci, uci = calc_odds_ratio(a,b,c,d)
          if or > 1 && lci > 1 #&& a >= 5
              println("$dsupp\$$ccs\$$or\$$lci\$$uci")
              write(outFile, "$dsupp\$$ccs\$$or\$$lci\$$uci\n")
          end
      end
  end
end

mysql_disconnect(db)
close(outFile)
