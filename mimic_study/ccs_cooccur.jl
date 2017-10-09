# Identify co-occurrenece of CCS categories from MIMIC data
# Sept 1, 2017

using MySQL
using Combinatorics

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


db = mysql_connect("localhost","root","","mimic_study")

ccs_array = mysql_execute(db, "select distinct ccs_cat from mimic_icd_ccs;")[1]

for comb in collect(combinations(ccs_array, 2))
    ccs_1 = comb[1]
    ccs_2 = comb[2]
    sub_arr1 = mysql_execute(db, "select distinct sub_id from mimic_icd_ccs where ccs_cat = \"$ccs_1\"")[1]
    sub_arr2 = mysql_execute(db, "select distinct sub_id from mimic_icd_ccs where ccs_cat = \"$ccs_2\"")[1]
    a = length(intersect(sub_arr1, sub_arr2))
    sub_arr1 = mysql_execute(db, "select distinct sub_id from mimic_icd_ccs where ccs_cat = \"$ccs_1\"")[1]
    sub_arr2 = mysql_execute(db, "select distinct sub_id from mimic_icd_ccs where ccs_cat != \"$ccs_2\"")[1]
    b = length(intersect(sub_arr1, sub_arr2))
    sub_arr1 = mysql_execute(db, "select distinct sub_id from mimic_icd_ccs where ccs_cat != \"$ccs_1\"")[1]
    sub_arr2 = mysql_execute(db, "select distinct sub_id from mimic_icd_ccs where ccs_cat = \"$ccs_2\"")[1]
    c = length(intersect(sub_arr1, sub_arr2))
    sub_arr1 = mysql_execute(db, "select distinct sub_id from mimic_icd_ccs where ccs_cat != \"$ccs_1\"")[1]
    sub_arr2 = mysql_execute(db, "select distinct sub_id from mimic_icd_ccs where ccs_cat != \"$ccs_2\"")[1]
    d = length(intersect(sub_arr1, sub_arr2))
    if a >= 5 && b >= 5 && c >= 5 && d >= 5
        or, lci, uci = calc_odds_ratio(a, b, c, d)
        println("$ccs_1\$$ccs_2\$$or\$$lci\$$uci")
    end
end

mysql_disconnect(db)
