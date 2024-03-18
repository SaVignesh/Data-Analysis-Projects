<H1> Nashville Housing Dataset - Data Cleaning using SQL and Visualization</H1>
Nashville Housing dataset contains information on Sales of Houses.  <Br>
This dataset contains columns for Parcel ID, Address, Sale Date, Sales Price etc. which needs to be cleaned before using for visualization.  The clean data will be used to create a report in Power BI. <Br> <Br>
The following data cleaning operations are performed in this project:
 <ul>
  <li>Removing TimeStamp from Sale Date column as all timestamps had value 00:00:00 </li>
  <li>Cleaning NULL values in Property Address column by using the address corressponding to Parcel ID</li>
  <li>Splitting Property Address column into Property Address and Property City columns </li>
  <li>Cleaning NULL values in Owner Address column using values present in Property Address </li>
  <li>Splitting Owner Address column into Owner Address, Owner City and Owner State columns </li>
  <li>Cleaning values in SoldAsVacant column by changing values 'Yes', 'Y', 'No', 'N' into values 'Yes' and 'No'</li>
   <li>Removing duplicate rows</li>
</ul> 
<H3>Report Created in Power BI</H3>

![Nashville Power Bi image](https://github.com/SaVignesh/Data-Analysis-Projects/assets/47379614/09c52e5e-5f62-40fe-b373-9d9298233bb3)
