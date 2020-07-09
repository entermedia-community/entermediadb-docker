how to use example

compare:
    cat ./compare.json | ./compare

profile: 
    ./profile ./image.jpeg
    ./profile ./john                #if john is a folder. it will go through all the files inside and create a profile of all the files as one


    #returns a new profile, array of array of doubles.
    # {
    #   profile: [[0.001,0.033,...]]
    # }



