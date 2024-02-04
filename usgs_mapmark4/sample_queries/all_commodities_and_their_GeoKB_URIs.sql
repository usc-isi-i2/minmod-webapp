SELECT ?ci ?cn ?gi
            WHERE {
                ?ci a :Commodity .
                ?ci :name ?cn .
                ?ci owl:sameAs ?gi .
            }