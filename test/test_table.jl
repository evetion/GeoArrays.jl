using Tables

ga = GeoArray(rand(2,2,2))
table = Tables.rows(ga)
@test length(collect(table)) == 4
@test Tables.schema(table) != nothing

ga = GeoArray(rand(2,2))
table = Tables.rows(ga)
@test length(collect(table)) == 4
