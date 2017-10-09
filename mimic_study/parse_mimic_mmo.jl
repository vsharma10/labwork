# Parse test custom metamap output file by file within a directory
# Aug 10, 2017
# Run: julia parse_mimic.jl <path_to_input_dir> <output_file>

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


#function parse_mmo(mmoFile, sem_arr)
#function parse_mmo(mmoFile)


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
              if ismatch(r"^\-[0-9]+\,\'HS[0-9]+", ev)
                evmatch = match(r"\-([0-9]+)\,\'(HS[0-9]+)\'\,.*\,.*\,\[(.*)\]\,\[([a-z]+.*[a-z]+)\]\,\[.*\]\,[a-z]+\,[a-z]+\,\[(.*)]\,\[.*\]\,[0-9]+\,[0-9]+\)", ev)
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



# Read all MetaMap output files from directory and writes parsed output to file
dir = ARGS[1]
ofile = ARGS[2]
outFile = open("$ofile", "w")


for file in readdir(dir)
  if ismatch(r".*mmout\.txt", file)
    println("Processing: $file")
    m = match(r"([0-9]+)\_([0-9]+)\_mmout\.txt", file)
    sub_id  = m.captures[1]
    hadm_id = m.captures[2]
    inpFile = open("$dir\/$file")
    mmoFile = readstring(inpFile)
    txt_arr = split(mmoFile, "\'EOU\'\.")
    txt_arr = remove_n(txt_arr)
    txt_arr = remove_e(txt_arr)
    for txt in txt_arr
      seg_arr = split(txt, "\n")
      out_arr = parse_mmo(seg_arr)
      for out in out_arr
        #println("$sub_id\$$hadm_id\$$out")
        write(outFile, "$sub_id\$$hadm_id\$$out\n")
      end
    end
    close(inpFile)
  end
end

close(outFile)
