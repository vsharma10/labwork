# Parse MetaMap machine output files from a given directory
# 23 Jan 2017
# julia parse_mmo.jl <path to directory> <output file>


function remove_empty(arr)
  while in("", arr)
    ind = findfirst(arr, "")
    deleteat!(arr, ind)
  end
  return arr
end


function parse_mmo(mmoFile, sem_arr)
  mmout_arr = Any[]
  for txt in split(mmoFile, "\'EOU\.\'")
    txtarr = split(txt, "\n")
    txtarr = remove_empty(txtarr)
    for line in txtarr
      if ismatch(r"mappings", line)
        if !ismatch(r"mappings\(\[\]\)", line)
          for m in split(line, "map\(")
            if ismatch(r"\-[0-9]+\,\[ev.*", m)
              scr1 = match(r"(\-[0-9]+)\,\[ev.*", m).captures[1]
              for ev in split(m, "ev\(")
                if ismatch(r"(-[0-9]+)\,\'(C[0-9]+)\'\,.*\,.*\,\[(.*)\]\,\[(.*)\]\,\[\[\[", ev)
                  evmatch = match(r"(-[0-9]+)\,\'(C[0-9]+)\'\,.*\,.*\,\[(.*)\]\,\[(.*)\]\,\[\[\[", ev)
                  #pmid = txtarr[1]
                  #println(ev)
                  scr2 = evmatch.captures[1]
                  cui  = evmatch.captures[2]
                  sem_nam = evmatch.captures[3]
                  sem_typ = evmatch.captures[4]
                  if in(sem_typ, sem_arr)
                    #println("$cui\|$sem_nam\|$sem_typ")
                    push!(mmout_arr, "$cui\|$sem_nam\|$sem_typ")
                  end
                  #println("$pmid\|$cui\|$sem_nam")
                  #write(outFile, "$pmid\|$cui\|$sem_nam\n")
                end
              end
            end
          end
        end
      end
    end
  end
  return unique(mmout_arr)
end

dir = ARGS[1]

ofile = ARGS[2]

outFile = open("$ofile", "w")

#mmoFile = readall("$file")
# Semantic types of semantic group "DISORDERS"
sem_arr = ["acab", "anab", "comd", "cgab", "dsyn", "emod", "fndg", "inpo", "mobd", "neop", "patf", "sosy"]

for file in readdir(dir)
  if ismatch(r".*\.txt", file)
    m = match(r"([A-Z][a-z]+.*)\_out\.txt", file)
    plnt_name = m.captures[1]
    plnt_name = replace(plnt_name, "\_", " ")
    mmoFile = readall("$dir\/$file")
    out_arr = parse_mmo(mmoFile, sem_arr)
    for out in out_arr
      println("$plnt_name\|$out")
      write(outFile, "$plnt_name\|$out\n")
    end
  end
end

close(outFile)
