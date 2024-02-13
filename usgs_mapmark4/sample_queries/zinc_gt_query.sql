SELECT ?mineralInventory ?tonnage  ?grade ?inventoryName ?category
                          WHERE {
                              ?mineralInventory a            :MineralInventory .
                              ?mineralInventory :id          ?inventoryName .

                              ?mineralInventory :date        '09-19-2017' .

                              ?mineralInventory :ore         ?ore .
                              ?ore              :ore_value   ?tonnage .

                              ?mineralInventory :grade       ?gradeInfo .
                              ?gradeInfo        :grade_value ?grade .

                              ?mineralInventory :commodity   ?Commodity .
                              ?Commodity        :name        'Zinc'@en .

                              ?mineralInventory :category    ?category .
                          }