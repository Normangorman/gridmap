map = []

30.times do |a|
	row = []
	50.times do |b|
		row << ['#', '.', '.', '.', '.', 'G', 'T'].sample
	end

	line = ""
	50.times do |c|
		line += row[c-1]
	end
	line += "\n"
	map << line
end


File.open("roadmap.txt", "w") do |f|
  map.each do |row| f << row end
end