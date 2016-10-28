#Sentence tokenization

using PyCall
@pyimport nltk as ntk

function sentTokenization(txt, ntk, id, tiab)
  sent_arr = ntk.sent_tokenize(txt)
  for i in 1:length(sent_arr)
    if i < length(sent_arr)
      if ismatch(r"[Nn]o\.\s[a-z0-9]", sent_arr[i] * " " * sent_arr[i+1]) || ismatch(r"[A-Za-z]\.\s[a-z0-9]", sent_arr[i] * " " * sent_arr[i+1])
        sent_arr[i] = sent_arr[i] * " " * sent_arr[i+1] #* "\."
        deleteat!(sent_arr, i+1)
      end
    end
  end
  if sent_arr[length(sent_arr)] == "" || isempty(sent_arr[length(sent_arr)])
    deleteat!(sent_arr, length(sent_arr))
  end
  nsent_arr = Any[]
  ln = 0
  for i in 1:length(sent_arr)
    if i == 1
      st = 1
      en = length(sent_arr[i])
      push!(nsent_arr, "$id\$$tiab\:$st\-$en\$$(sent_arr[i])")
      ln = en
    else
      st = ln + 2
      en = st + length(sent_arr[i])
      push!(nsent_arr, "$id\$$tiab\:$st\-$en\$$(sent_arr[i])")
      ln = en
    end
  end
  return nsent_arr
end

function tokenarr(sent, lnarr, wmcarr)
  #csent = match(r"[0-9]+\:[0-9]+\$(.*)", sentstr)
  #sent = csent.captures[1]
  #println(stPos * "\$" * enPos * "\$" * sent)
  m = matchall(r"([a-z0-9][a-z0-9]{4,}\-[a-z0-9][a-z0-9]{4,})"i, sent)
  # change from previous
  if size(m)[1] > 0
    for str in m
      str1 = replace(str, r"\-", " ")
      sent = replace(sent, "$str", "$str1")
    end
  end
  for ln in lnarr
    ln = lowercase(ln)
    if contains(sent, ln)
      ln1 = replace(ln, r"\s", "\-")
      sent = replace("$sent", "$ln", "$ln1")
    end
  end

  #m1 = matchall(r"([a-z0-9][a-z0-9]+\s[a-z0-9])[\s$\)\]\.]"i, sent)
  # change from previous
  #if size(m1)[1] > 0
  #  for str in m1
  #    str1 = replace(str, r"\s", "\-")
  #    sent = replace(sent, "$str", "$str1")
  #  end
  #end

  iword_arr = Any[]
  for word in split(sent, r"[\s\/]")
    word = chomp(word)
#    if ismatch(r"[\,\-\:\;\}]$", word)
    if ismatch(r"[\,\:\;\}]$", word)
      word = chop(word)
    end
    if ismatch(r"^[\(\"\'].*[\)\"\'\{]$", word)
      word = word[2:end-1]
    end
    if ismatch(r"^non\-", word)
      word = word[5:end]
    end
    if ismatch(r"^[\'\"]", word)
      word = word[2:end]
    end
    if ismatch(r"[\'\"]$", word)
      word = chop(word)
    end
    if ismatch(r"\'s$", word)
      word = chop(word)
      word = chop(word)
    end
    if ismatch(r"s\'$", word)
      word = chop(word)
      word = chop(word)
    end
    if ismatch(r"\.$", word)
      word = chop(word)
    end
    if ismatch(r"[\)\]][\)\]]$", word)
      word = chop(word)
    end
    if ismatch(r"^[A-Za-z0-9]", word) && ismatch(r"[A-Za-z0-9][\)\]]$", word)
      if !(ismatch(r"[\(\]]", word))
        word = chop(word)
      end
    elseif ismatch(r"^[\(\[][A-Za-z0-9]", word) && ismatch(r"[A-Za-z0-9]$", word)
      if !(ismatch(r"[\)\]]", word))
        word = word[2:end]
      end
    elseif ismatch(r"^[\(][\[\(A-Za-z0-9]", word) && ismatch(r"[A-Za-z0-9]$", word)
      if !(ismatch(r"[\)]", word))
        word = word[2:end]
      end
    elseif ismatch(r"^[\[][\[\(A-Za-z0-9]", word) && ismatch(r"[A-Za-z0-9]$", word)
      if !(ismatch(r"[\]]", word))
        word = word[2:end]
      end
    end

    if ismatch(r"[A-Za-z]", word) && !(ismatch(r"[\=\>\<\/]", word)) && !(ismatch(r"\-\-", word))
      wordlc = lowercase(word)
      if in(wordlc, wmcarr) == false
        push!(iword_arr, word)
      end
    end
  end
  #println(iword_arr)
  #moved from top
    #sent = lowercase(sent)
  ma = matchall(r"[a-z]+\-[a-z]+\-[a-z]"i, lowercase(sent))
  if size(ma)[1] > 0
    for sr in ma
      sr1 = replace(sr, r"\-", " ")
      sent = replace(sent, "$sr", "$sr1")
    end
  end
  # change from previous modified to include numbers
  m = matchall(r"([a-z0-9][a-z0-9]+\-[a-z0-9][a-z0-9]+)"i, sent)
  # change from previous
  if size(m)[1] > 0
    for str in m
      str1 = replace(str, r"\-", " ")
      sent = replace(sent, "$str", "$str1")
    end
  end

  #moved from top
  word_arr = Any[]
  for word in split(sent, r"[\s\/]")
    word = chomp(word)
#    if ismatch(r"[\,\-\:\;\}]$", word)
    if ismatch(r"[\,\:\;\}]$", word)
      word = chop(word)
    end
    if ismatch(r"^[\(\"\'].*[\)\"\'\{]$", word)
      word = word[2:end-1]
    end
    if ismatch(r"\(s\)$", word)
      word = word[1:end-3]
    end
    if ismatch(r"^[\'\"]", word)
      word = word[2:end]
    end
    if ismatch(r"^non\-", word)
      word = word[5:end]
    end
    if ismatch(r"[\'\"]$", word)
      word = chop(word)
    end
    if ismatch(r"\'s$", word)
      word = chop(word)
      word = chop(word)
    end
    if ismatch(r"s\'$", word)
      word = chop(word)
      word = chop(word)
    end
    if ismatch(r"\.$", word)
      word = chop(word)
    end
    if ismatch(r"[\)\]][\)\]]$", word)
      word = chop(word)
    end
    if ismatch(r"^[A-Za-z0-9]", word) && ismatch(r"[A-Za-z0-9][\)\]]$", word)
      if !(ismatch(r"[\(\]]", word))
        word = chop(word)
      end
    elseif ismatch(r"^[\(\[][A-Za-z0-9]", word) && ismatch(r"[A-Za-z0-9]$", word)
      if !(ismatch(r"[\)\]]", word))
        word = word[2:end]
      end
    elseif ismatch(r"^[\(][\(A-Za-z0-9]", word) && ismatch(r"[A-Za-z0-9]$", word)
      if !(ismatch(r"[\)]", word))
        word = word[2:end]
      end
    elseif ismatch(r"^[\[][\[A-Za-z0-9]", word) && ismatch(r"[A-Za-z0-9]$", word)
      if !(ismatch(r"[\]]", word))
        word = word[2:end]
      end
    end

    if ismatch(r"[A-Za-z]", word) && !(ismatch(r"[\=\>\<\/\.]", word)) && !(ismatch(r"\-\-", word))
      wordlc = lowercase(word)
      if in(wordlc, wmcarr) == false
        push!(word_arr, word)
      end
    end
  end
  newarr = Any[]
  for iwrd in setdiff(iword_arr, word_arr)
    push!(word_arr, iwrd)
  end
  newarr = intersect(word_arr, iword_arr)
  word_arr = setdiff(word_arr, newarr)
  iword_arr = setdiff(iword_arr, newarr)
  #println(iword_arr)
  #println("Hello World")
  #println(word_arr)

  #println(newarr)
  #newarr = Any[]
  for wrd1 in word_arr
    for wrd2 in iword_arr
      if wrd1 == wrd2
        push!(newarr, wrd1)
        a = findfirst(iword_arr, wrd2)
        #deleteat!(iword_arr, a)
        iword_arr[a] = ""
      elseif contains(wrd2, wrd1) == true && wrd1 != wrd2
        push!(newarr, wrd2)
        n = findfirst(iword_arr, wrd2)
        #deleteat!(iword_arr, n)
        iword_arr[n] = ""
        #end
      end
    end
  end
  return newarr
end

function forTokenization(spwordFile)
  lnarr = Any[]
  for ln in eachline(spwordFile)
    ln = chomp(ln)
    push!(lnarr, ln)
  end
  return lnarr
end

function ncwordList(wmcFile)
  wmcarr = Any[]
  for ln in eachline(wmcFile)
    ln = chomp(ln)
    push!(wmcarr, ln)
  end
  return wmcarr
end

function findindex(sent, token_arr)
  tokind_arr = Any[]
  sent1 = replace(sent, r"[^A-Za-z0-9]", "\*")
  for tok in token_arr
    tok1 = replace(tok, r"[^A-Za-z0-9]", "\*")
    tok_ind = search(sent1, tok1)
    tok_str = string(tok_ind)
    tok_ind = [parse(Int, split(tok_str, "\:")[1]), parse(Int, split(tok_str, "\:")[2])]
    st = 0
    ind_st = tok_ind[1]
    ind_en = tok_ind[2]
    while tok_ind[1] > 0
      #println("$ind_st\:$ind_en\$$tok")
      push!(tokind_arr, "$ind_st\:$ind_en\$$tok")
      st = st+tok_ind[2]
      tok_str = string(search(sent1[st:end], tok1))
      tok_ind = [parse(Int, split(tok_str, "\:")[1]), parse(Int, split(tok_str, "\:")[2])]
      ind_st = tok_ind[1] + st - 1
      ind_en = tok_ind[2] + st - 1
    end
  end
  tokind_arr = unique(tokind_arr)
  return tokind_arr
end

function rulMatch(warr, chem_dict)
  scr = 0
  cwscr = 1
  csum = 0
  for str in warr
    c1, c2, ind = split(str, r"\|")
    ind = parse(Int, ind)
    if ind <= 20
      cscr = float(chem_dict["$c1\|$c2\|$ind"])
      if cscr >= 0.95 || cscr <= 0.05
      #if cscr >= 0.90 || cscr <= 0.10
        csum = csum + 1
        cscr = 1 - cscr
        cwscr = cwscr * cscr
      end
    end
  end
  cwscr = 1 - cwscr
  cwscr = round(cwscr, 5)
  #if csum > 0 && cwscr > 0.95
  if csum > 0 && cwscr >= 0.97
    scr = 1
  end
  return scr
end

# Splits word in to elements indicating characters and their seperation distance
function splitWord(word)
  word = ASCIIString(word)
  wordarr = Any[]
  chararr = split(word, "")
  siz = size(chararr)[1]
  for i in 1:siz
    n = 0
    if ismatch(r"[^A-Za-z0-9\s]", chararr[i])
      chararr[i] = "[^A-Za-z0-9\s]"
    elseif ismatch(r"\s", chararr[i])
      chararr[i] = "[s]"
    end
    for j in (i+1):siz
      n = n + 1
      if ismatch(r"[^A-Za-z0-9\s]", chararr[j])
        chararr[j] = "[^A-Za-z0-9\s]"
      elseif ismatch(r"\s", chararr[j])
        chararr[j] = "[s]"
      end
      if n < 6
        if !(ismatch(r"\[s\]", chararr[i])) && !(ismatch(r"\[s\]", chararr[j]))
          push!(wordarr, "$(chararr[i])|$(chararr[j])|$n")
        end
      end
    end
  end
  return wordarr
  empty!(wordarr)
end

#looks up tokens in dictionary
function checkDictionary(token, jo_array)
  #chemarr = Any[]
  scr = 0
  tokenlc = lowercase(token)
  if in(tokenlc, jo_array)
    scr = 1
  end
  return scr
end

function getKey(dict, id)
  arr = Any[]
  for (k, v) in dict
    if v == id
      push!(arr, k)
    end
  end
  return arr[1]
end


function multiword(abnew_arr)

  pvabnew_arr = abnew_arr
  lnpv = length(pvabnew_arr)
  lnnew = 0
  while lnpv != lnnew
    i = 2
    lnpv = length(pvabnew_arr)
    for abnew in abnew_arr
      if i <= length(abnew_arr)
        m1 = match(r"([0-9]+\:[0-9]+)\$(.*)$", abnew_arr[i-1])
        #println(m1.captures[1])
        pen = parse(Int, split(m1.captures[1], r"\:")[2])
        pst = parse(Int, split(m1.captures[1], r"\:")[1])
        #println(i)
        m2 = match(r"([0-9]+\:[0-9]+)\$(.*)$", abnew_arr[i])
        st = parse(Int, split(m2.captures[1], r"\:")[1])
        en = parse(Int, split(m2.captures[1], r"\:")[2])
        if st - pen == 2
          abnew_arr[i-1] = "$pst\:$en\$$(m1.captures[2]) $(m2.captures[2])"
          deleteat!(abnew_arr, i)
        end
      end
      i = i + 1
    end
    lnnew = length(abnew_arr)

    pvabnew_arr = abnew_arr
    #println(abnew_arr)
  end

  i = 2
  for abnew in abnew_arr
    if i <= length(abnew_arr)
      m1 = match(r"([0-9]+\:[0-9]+)\$(.*)$", abnew_arr[i-1])
      #println(m1.captures[1])
      pen = parse(Int, split(m1.captures[1], r"\:")[2])
      pst = parse(Int, split(m1.captures[1], r"\:")[1])
      #println(i)
      m2 = match(r"([0-9]+\:[0-9]+)\$(.*)$", abnew_arr[i])
      st = parse(Int, split(m2.captures[1], r"\:")[1])
      en = parse(Int, split(m2.captures[1], r"\:")[2])
      if st >= pst && en <= pen
        deleteat!(abnew_arr, i)
      end
    end
    i = i + 1
  end
  return abnew_arr
end

function sort_index(reschem_array)
  abdict = Dict{Any, Any}()
  abnew_arr = Any[]

  for res in reschem_array
    abdict["$res"] = parse(Int, "$(split(split(res, "\$")[1], "\:")[1])")
  end
  for val in sort(collect(values(abdict)))
    push!(abnew_arr, "$(getKey(abdict, val))")
  end
  return abnew_arr
end


dictFile = open("/Users/sharma/Desktop/BioCreativeV5/joChem/jochem_dictionary.txt")
#rulDict = Dict{Any,Any}()
jo_array = Any[]
for ln in eachline(dictFile)
  ln = chomp(ln)
  ln = lowercase(ln)
  id = split(ln, r"\$")[1]
  name = split(ln, "\$")[2]
  #rulstr = split(ln, r"\$")[4:end]
  #rulstr = join(rulstr, "\|")
  #rulDict[name] = rulstr
  #idDict[name] = id
  push!(jo_array, lowercase(name))
end


#Store rule identified from chemical list and returns a dictionary
ruleFile = open("/Users/sharma/Desktop/cner_3/chemrules-normsdist.csv")

#function ruleDictionary(ruleFile)
chem_dict = Dict{Any, Any}()
for ln in eachline(ruleFile)
  ln = chomp(ln)
  for ln in split(ln, r"\r")
    if ismatch(r".*\,.*\,.*\,.*\,.*", ln)
      scrs = match(r"(.*\,.*\,.*)\,.*\,(.*)", ln)
      c1c2ind = scrs.captures[1]
      c1c2ind = replace(c1c2ind, r"\,", "\|")
      scrs = scrs.captures[2]
      chem_dict[c1c2ind] = scrs
    end
  end
end


spwordFile = open("/Users/sharma/Desktop/chem_tool/evaluation-20151112/names-with-spaces20151130.txt")
lnarr = forTokenization(spwordFile)
wmcFile = open("/Users/sharma/Desktop/BioCreativeV5/cemp_test/wordmchem_0-90wadd-20161026.txt")
wmcarr = ncwordList(wmcFile)

norm = ARGS[1]
file = ARGS[2]

if norm == "\-n"
  println("With Normalization")
  println("")
elseif norm == "\-i"
  println("No Normalization")
  println("")
end


inFile = open("$file")

for ln in eachline(inFile)
  ln = chomp(ln)
  id, ti, txt = split(ln, r"\t")
  token_arr = unique(tokenarr(txt, lnarr, wmcarr))
  tokind_arr = findindex(txt, token_arr)
  #println(tokind_arr)

  reschem_array = Any[]
  for tokind in tokind_arr
    ind = match(r"([0-9]+\:[0-9]+)\$(.*)", tokind).captures[1]
    word = match(r"([0-9]+\:[0-9]+)\$(.*)", tokind).captures[2]
    cwordlc = lowercase(word)
    dict_chem = checkDictionary(cwordlc, jo_array)
    warr = splitWord(cwordlc)
    scr = rulMatch(warr, chem_dict)
    if dict_chem == 1
      #println("$ind\$$word\$$dict_chem")
      push!(reschem_array, "$ind\$$word")
    elseif scr == 1
      #println("$ind\$$word\$$scr")
      push!(reschem_array, "$ind\$$word")
    end
  end
#end
  abnew_arr = sort_index(reschem_array)
  #println(abnew_arr)
  #abnew_arr = unique(abnew_arr)

  #println(length(abnew_arr))

  finalarr = multiword(abnew_arr)
  println(finalarr)

  #for res in abnew_arr
  #  println("$id\$$res")
  #end
  #while i < length(abnew_arr)
  #  ind =
  #end
end
  #ti_arr = sentTokenization(ti, ntk, id, "T")
  #=
  for indsent in ti_arr
    println(indsent)
    sent = match(r"[A-Z0-9]+\$[TA]\:[0-9]+\-[0-9]+\$(.*)", indsent).captures[1]
    token_arr = unique(tokenarr(sent, lnarr, wmcarr))
    println(token_arr)
    findindex(sent, token_arr)
  end
  =#
  #txt_arr = sentTokenization(txt, ntk, id, "A")

  #for indsent in txt_arr
    #println(indsent)
    #sent = match(r"[A-Z0-9]+\$[TA]\:[0-9]+\-[0-9]+\$(.*)", indsent).captures[1]
    #token_arr = unique(tokenarr(sent, lnarr, wmcarr))
    #println(token_arr)
  #end
#end
