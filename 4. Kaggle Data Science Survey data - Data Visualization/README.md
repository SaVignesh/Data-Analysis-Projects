<H3>Kaggle Data Science Survey data - Data Visualization</H3>
Data Source: https://www.kaggle.com/c/kaggle-survey-2022/data <Br> <Br>
Kaggle Data Science Survey is taken by students and professionals in Data Science workspace and the results are stored in a CSV file.
The data contains the responses given by the Survey takers for questions like 'what is your country?', 'Which platform did you find the most helpful when you first
started studying data science', etc.  
The following operations were performed in this project: 
<ul>
  <li>Concatenated first two rows to get the complete question and make the question as the column header</li>
  <li>Created a custom column Age Bracket for Adolescent(18-29), Middle Aged (30,49) and Elderly (50+)</li>
  <li> There are multiple choice questions in the survey and the answers for that question is entered in multiple columns.  <Br>
For example, Question 7 is "Which product or platform did you find the most helpful when you first started studying data science".  <Br>
There are options:  <Br> &nbsp;
● University courses  <Br> &nbsp;
● Online courses (Coursera, EdX, etc)  <Br> &nbsp;
● Social media platforms (Reddit, Twitter, etc)  <Br> &nbsp;
● Video platforms (YouTube, Twitch, etc)  <Br> &nbsp;
● Kaggle (notebooks, competitions, etc)  <Br> &nbsp;
● None / I do not study data science  <Br> &nbsp;
● Other   <Br>
    If the survey taker selects 'University courses', then the column for 'University courses' will have the value while the columns for other options will be blank.
If the survey taker selects 'University courses' and 'other', both columns will contain values while the rest of the columns will be blank.
We cannot directly visualize answers for this question as the values are present in multiple columns.


</li>
<li>So, Added Question 7 to another query and unpivoted it so that all the values in Q7 are present in a single column and can be used for visualization.</li>
</ul>
