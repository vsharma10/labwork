# Parse metamap processed (DEFAULT METAMAP) output of MEDLINE abstracts
# Aug 21, 2017
# Run: julia parse_medline.jl <path_to_input_file> <output_file>

function remove_n(arr)
  while in("\n", arr)
    ind = findfirst(arr, "\n")
    deleteat!(arr, ind)
  end
  return arr
end

function remove_e(arr)
  while in("", arr)
    ind = findfirst(arr, "")
    deleteat!(arr, ind)
  end
  return arr
end



function parse_mmo(seg_arr)
  out_arr = Any[]
  for seg_str in seg_arr
    if ismatch(r"mappings", seg_str)
      if !ismatch(r"mappings\(\[\]\)", seg_str)
        for m in split(seg_str, "map\(")
          if ismatch(r"\-[0-9]+\,\[ev.*", m)
            map_scr = match(r"(\-[0-9]+)\,\[ev.*", m).captures[1]
            #println(scr1)
            for ev in split(m, "ev\(")
              if ismatch(r"^\-[0-9]+\,C[0-9]+", ev)
                evmatch = match(r"\-([0-9]+)\,(C[0-9]+)\,.*\,.*\,\[(.*)\]\,\[([a-z]+.*[a-z]+)\]\,\[\[.*\,[a-z]+\,[a-z]+\,\[(.*)]\,\[.*\]\,[0-9]+\,[0-9]+\)", ev)
                evscr   = evmatch.captures[1]
                evcui   = evmatch.captures[2]
                evstr   = evmatch.captures[3]
                evsty   = evmatch.captures[4]
                evsrc   = evmatch.captures[5]
                push!(out_arr, "$evscr\$$evcui\$$evstr")
              end
            end
          end
        end
      end
    end
  end
  return out_arr
end



# Read MetaMap output file and write parsed output to file:
# OUTPUT: PMID$SCORE$UMLS_CUI$UMLS_STRING

infile = ARGS[1]
ofile  = ARGS[2]
outFile = open("$ofile", "w")

inFile = open("$infile")
mmoFile = readstring(inFile)
txt_arr = split(mmoFile, "\'EOU\'\.")
txt_arr = remove_n(txt_arr)
txt_arr = remove_e(txt_arr)
for txt in txt_arr
  seg_arr = split(txt, "\n")
  seg_arr = remove_n(seg_arr)
  seg_arr = remove_e(seg_arr)
  #println(seg_arr)
  out_arr = parse_mmo(seg_arr)
  #println(seg_arr)
  pmid    = seg_arr[1]
  for out in unique(out_arr)
    println("$pmid\$$out")
    write(outFile, "$pmid\$$out\n")
  end
end

close(inFile)
close(outFile)
