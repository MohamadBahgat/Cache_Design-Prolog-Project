# Prolog-Cache_Project (Worked on it alone)
Cache is a component that stores data so that future requests for that data can be
served faster. Recently or frequently used data are stored temporarily in the cache
to speed up the retrieval of the data by reducing the time needed for accessing
cache clients data such as the CPU.
In this project you must present a successful implementation of a simplified
CPU cache system that works by retrieving data (from cache if possible, otherwise
from memory) given the memory addresses of the data and successfully updating
the cache upon the data retrieval.
The idea of a cache is that it introduces hierarchy into memory systems. Thus,
instead of having one level for a large memory which will probably be slow because
it needs to be cheap, we can have multiple levels.
