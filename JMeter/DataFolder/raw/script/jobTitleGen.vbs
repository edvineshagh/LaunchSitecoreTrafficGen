

one=  Array("","Lead", "Senior","Direct", "Corporate", "Dynamic", "Future", "Product", "National", "Regional", "District", "Central", "Global", "Customer", "Investor", "Dynamic", "International", "Legacy", "Forward", "Internal", "Human", "Chief", "Principal")

two = Array("","Solutions", "Program", "Brand", "Security", "Research", "Marketing", "Directives", "Implementation", "Integration", "Functionality", "Response", "Paradigm", "Tactics", "Identity", "Markets", "Group", "Division", "Applications", "Optimization", "Operations", "Infrastructure", "Intranet", "Communications", "Web", "Branding", "Quality", "Assurance", "Mobility", "Accounts", "Data", "Creative", "Configuration", "Accountability", "Interactions", "Factors", "Usability", "Metrics")

three = Array("Supervisor", "Associate", "Executive", "Liason", "Officer", "Manager", "Engineer", "Specialist", "Director", "Coordinator", "Administrator", "Architect", "Analyst", "Designer", "Planner", "Orchestrator", "Technician", "Hardware","Software", "Chemical""Sanitation","Developer", "Producer", "Consultant", "Assistant", "Facilitator", "Agent", "Representative", "Strategist")

for i = 1 to 10000
		i1 = rnd * 100 mod (ubound(one)+1)
		i2 = rnd * 100 mod (ubound(two)+1)
		i3 = rnd * 100 mod (ubound(three)+1)
		title = replace(rtrim(ltrim(one(i1) & " " & two(i2) & " " & three(i3))), "  ", " ")
		wscript.echo title
next