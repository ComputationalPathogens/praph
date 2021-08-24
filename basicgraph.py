import pickle

#node - seq, id, 'placement' of kmer in a sample path the indices that occur within a path, super basic so no actualy edges
#       id, (pathid, pathind) seq : (id, dict[pathid]:[(indinpath,connectedNodeId), ]
nodegraph = {}
uidmap = {}
def make_nodes(k, seq, pathid):
    ind = 0
    seqind = 0
    kmers = []
    while seq != "":
            kmers.append((seq[:k])) #split string into k-mers (non-overlapping)
            seq = seq[k:]
            ind+=k
            
    kmers.insert(0, '$') #insert $ at beginning of kmers for start token mapping
    leng = len(kmers)+1
    kmers.append('#') #insert # at end of kmers for end token mapping
    currind = len(nodegraph.keys()) #any new kmers we make will have an index one greater than the current highest
        

    #add all new kmers into kmer map and give them new id
    for km in kmers: 
        if km not in nodegraph: #if this is a new kmer, add it to our 'graph' and uid reverse lookup
            nodegraph[km] = (currind, {})
            uidmap[currind] = km
            currind += 1
    #now that all kmers are known we can add the paths
    for x in range(1,leng):
        if pathid not in nodegraph[kmers[x-1]][1]: #if this kmer has never shown up in this path/sample
            nodegraph[kmers[x-1]][1][pathid] = {seqind:nodegraph[kmers[x]][0]} #create a new dict with path/sampleid as key, adding another
        else:                                                                  #dict with index of current node in this sequence mapped to which kmer it connects to
            nodegraph[kmers[x-1]][1][pathid][seqind] = nodegraph[kmers[x]][0]  #else, the dict already exists so we add another sequenceindex:connection entry
        seqind += 1 #process next node in this path/sequence
    pathid += 1 #increment path counter for when we process next path
    return nodegraph, pathid

def get_files(inp):
    with open(inp) as f:
        alist = [line.rstrip() for line in f]

    test = ''.join(alist)
    return test

def trace_path(pathid):
    seq = []
    count = 0
    start = '$'
    while uidmap[nodegraph[start][0]] != '#': #start at the start character '$' and follow the edges based on current index
        seq += uidmap[nodegraph[start][1][pathid][count]] #adding results until we reach the end character '#' and return the result
        start = uidmap[nodegraph[start][1][pathid][count]]
        count+=1
    
    return "".join(seq)

#Simple saving and loading of the graph/reverse lookup as a pickle file
def save_dict(nodes, seqs):
    with open('nodes.pkl', 'wb') as f:
        pickle.dump(nodes, f, pickle.HIGHEST_PROTOCOL)
    with open('seqids.pkl', 'wb') as f:
        pickle.dump(seqs, f, pickle.HIGHEST_PROTOCOL)
        
def load_dict():
    out1, out2 = "",""
    with open('nodes.pkl', 'rb') as f:
        out1 = pickle.load(f)
    with open('seqids.pkl', 'rb') as f:
        out2 = pickle.load(f)
    return out1, out2
"""
nodegraph structure = dict{seqasstring: (seq id, dict{sampleid : dict{currind:connectingnodeid}})
"""
def seqmatch(match):
    for x in range(3): #3 is just the amount of samples I have at the moment
        count = 0
        curseq = ""
        start = '$'
        while uidmap[nodegraph[start][0]] != '#':              #similar to path trace but we arent saving the path, just checking each one
            curseq = uidmap[nodegraph[start][1][x][count]]     #for a match to the kmers. Depending on length of search string we
            start = curseq                                     #need to be checking multiple consecutive k-mers at once incase there
            if curseq != '#':                                  #is overlap in the match string over edges. Every search needs to check at least 
                curseq += uidmap[nodegraph[curseq][1][x][count+1]] 
            try:                                               #two consecutive k-mers, matching larger sequences would need more 
                curseq.index(match) #check if match string exists in current search space returning its index:offset if it does
            except ValueError:
                count += 1
            else:
                return (x, count, curseq.index(match), curseq)

def main():

    a,b,c = get_files("test1.txt"), get_files("test2.txt"), get_files("test3.txt")
    res = make_nodes(11, a, 0)       
    res = make_nodes(11, b, res[1])
    res = make_nodes(11, c, res[1])
    print(trace_path(0) == (a + '#'))
    print(trace_path(1) == (b + '#'))
    print(trace_path(2) == (c + '#'))
    match = seqmatch("TTTCCTTTACCTTGT")
    print("Sample#: ", match[0], " At[kmerindex:offset]: ", match[1], ":", match[2], "   found in: ", match[3])
    save_dict(nodegraph, uidmap)
#nodemap, uidmap = load_dict()
main()

