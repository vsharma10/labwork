# Isolated PubMed articles with query: "mental disorders"[mh] AND dietsuppl[sb]
# Save the output in XML format
# This script will parse XML file and create output as: PMID$<TITLE & ABSTRACT>
# August 19, 2017

function parse_pubmed_xml(xroot)
  article_array = Any[]
  for c in child_nodes(xroot)
    if name(c) == "PubmedArticle"
      pmid = ""
      title = ""
      for c1 in child_nodes(c)
        #println(name(c1))
        if name(c1) == "MedlineCitation"
          for c2 in child_nodes(c1)
            #println(name(c2))
            if name(c2) == "PMID"
              pmid = content(c2)
            elseif name(c2) == "Article"
              for c3 in child_nodes(c2)
                #println(name(c3))
                if name(c3) == "ArticleTitle"
                  title = content(c3)
                elseif name(c3) == "Abstract"
                  txt = ""
                  for c4 in child_nodes(c3)
                    #println(name(c4))
                    if name(c4) == "AbstractText"
                      txt = txt * " " * strip(content(c4))
                    end
                  end
                  tiab = strip(title) * " " * strip(txt)
                  push!(article_array, "$pmid\$$tiab")
                end
              end
            end
          end
        end
      end
    end
  end
  return article_array
end

using LightXML

ouFile = open("./pubmed/mhealth_ds-subset.txt","w")
xdoc   = parse_file("./pubmed/pubmed_mh_ds-subset.xml")
xroot  = root(xdoc)

for article in parse_pubmed_xml(xroot)
  println(article)
  write(ouFile, "$article\n")
end

close(ouFile)
