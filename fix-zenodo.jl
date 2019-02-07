#!/usr/local/bin/julia

using JSON, DataStructures, Unicode

function fix_zenodo()
  if !isfile(".zenodo.json")
    error("No file .zenodo.json to fix")
  end
  data = JSON.parsefile(".zenodo.json", dicttype=DataStructures.OrderedDict)

  # Why read(`git ..`) not working?
  tmp = tempname()
  run(pipeline(`git shortlog -s`, stdout=tmp, stderr=tmp))
  for line in readlines(tmp)
    author = split(line, "\t")[2]

    # Looking for author
    found = false
    for creator in data["creators"]
      if author == creator["name"] || # Complete match
        all([occursin(part, creator["name"]) for part in split(author)])
        @info("Matched `$author` with `$(creator["name"])`")
        found = true
        break
      end
    end
    if !found && haskey(data, "contributors")
      for contrib in data["contributors"]
        if author == contrib["name"] || # Complete match
          all([occursin(part, contrib["name"]) for part in split(author)])
          @info("Matched `$author` with `$(contrib["name"])`")
          found = true
          break
        end
      end
    end

    found && continue

    @info("Adding $author")

    if !haskey(data, "contributors")
      data["contributors"] = Array{Dict{String, String}, 1}()
    end

    push!(data["contributors"], Dict("name" => author, "type" => "Researcher/Other"))
  end

  # License fix
  if !haskey(data, "license")
    licensefile = readlines("LICENSE.md")
    data["license"] = if any(occursin.("MPL", licensefile))
      "MPL-2.0"
    elseif any(occursin.("MIT", licensefile))
      "MIT"
    else
      "fixme"
    end
  end

  open(".zenodo.json", "w") do io
    JSON.print(io, data, 2)
  end
end

fix_zenodo()
