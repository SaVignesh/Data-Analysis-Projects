<H1> Nashville Housing Dataset - Data Cleaning using SQL</H1>
Nashville Housing dataset contains information on Sales of Houses.  <Br>
This dataset contains columns for Address, Sale Date, Sales Price etc. which needs to be cleaned before using for visualization. <Br>
On viewing the data in Microsoft SQL Server, it is oberved that the Sale Date column is a datetime datatype. Since, the original data did not have any time present in the data, the timestamp 00:00:00 is added at the end of date values. So first, we remove the timestamp from this column
