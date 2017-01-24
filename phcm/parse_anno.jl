# Parse annotation output files from Stanford Manual Annotation Tool
# 23 Jan 2017


function parse_anno(annoFile)
  anno_arr = Any[]
  for ln in eachline(annoFile)
    ln = chomp(ln)
    if ismatch(r"\<tag name\=\"Treatment\" value\=\"start\"\/\>", ln)
      #println(ln)
      stpos = search(ln, "\<tag name\=\"Treatment\" value\=\"start\"\/\>")
      enpos = search(ln, "\<tag name\=\"Treatment\" value\=\"end\"\/\>")

      while string(stpos) != "0\:\-1"
        #println("$stpos \=\> $enpos")
        #println(ln[stpos[end]+1:enpos[1]-1])
        push!(anno_arr, ln[stpos[end]+1:enpos[1]-1])
        stpos = search(ln, "\<tag name\=\"Treatment\" value\=\"start\"\/\>", stpos[end]+1)
        enpos = search(ln, "\<tag name\=\"Treatment\" value\=\"end\"\/\>", enpos[end]+1)
      end

    end
  end
  return unique(anno_arr)
end


dir = ARGS[1]

ofile = ARGS[2]

outFile = open("$ofile", "w")

for file in readdir(dir)
  if ismatch(r".*\.txt", file)
    m = match(r"([A-Z][a-z]+.*)\_ascii\.txt", file)
    plnt_name = m.captures[1]
    plnt_name = replace(plnt_name, "\_", " ")
    annoFile = open("$dir\/$file")
    out_arr = parse_anno(annoFile)
    for out in out_arr
      println("$plnt_name\|$out")
      write(outFile, "$plnt_name\|$out\n")
    end
  end
end

close(outFile)
