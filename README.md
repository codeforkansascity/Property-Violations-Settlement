[![Stories Ready to Work On](https://badge.waffle.io/zmon/Property-Violations-Settlement.svg?label=ready&title=Cards%20Ready%20To%20Work%20On)](https://waffle.io/zmon/Property-Violations-Settlement)

#Overview
Kansas City has led the way in opening up city data for analysis. This site focuses on one particular trove of data: information on violations of city codes relating to real property.

Code violations encompass a large range of problems: from overgrown weeds and trash dumping to structural issues when property is not properly maintained. The CodeForKC property violations project mines the property violations data for insights and considers ways to use the data.

#Project Website
The [project website](http://codeforkc.org/Property-Violations-Settlement/) serves as the primary documentation about the project and includes information about the project and the data, as well as results from data analysis.

#Getting Started
1. You will need to download and install [R](https://www.r-project.org/)
2. We highly recommend that you also download and install [R Stuidio](https://www.rstudio.com/products/rstudio/)
3. Follow [this](https://support.rstudio.com/hc/en-us/articles/200532077-Version-Control-with-Git-and-SVN) guide to set up github to work with RStudio. 
4. Check out the [Getting Started video](https://www.youtube.com/watch?v=xVjcfoTJBIM) that introduces the project and describes the startup script (violaions_main.R). The R directory has changed a little since that video was recorded, but the central thrust of the video is still relevant. Make sure you have installed all the libraries that are loaded at the top of violations_main.R before trying to run the script yourself.

#Project Structure
The purpose of each directory is described in a readme file in the directory. The R directory specifically includes two subdirectories: library and analysis. The library directory contains utility scripts that define functions for working with violations data. The analysis directory contains scripts that attempt to use those functions and embedded code to analyze the violations data.

#Using Census Data
The project features some easy-to-use functions for finding and joining census data with violations data. It relies on a robust R package called "acs" for that purpose. Some things to remember/know when using the acs package to fetch census data:

1. As with all the required libraries at the top of violations_main.R, be sure the acs package is installed.
2. Tell the acs package your census api key using “api.key.install(‘your key here’)”. If you need a key, go to http://www.census.gov/developers/ and click the “Request a Key” button on the left. It’s a quick and simple process.
3. Helper functions that simplify the acs package are located in the “R/library/census.R” script.
4. To search the census tables for data you might want to explore, use the lookupCensusTable(‘search term’) function. The search term can be a string or a vector of strings (which will be combined with “and”). This is obviously not the only way to explore the available data. For instance, http://censusreporter.org provides an as-you-type search box that is really easy to use.
5. To fetch census data, you have to define the geography you’re interested in. The helper function getKcGeo() returns a nice geographic definition that includes all the blockgroups in the counties that contain KC.
6. To see the KC metro area data for a table you think might be interesting, use the getCensusTableAsDataframe(‘your table number here’) function.
7. To join any census data to our violations data, just use the joinWithCensusData() function. Example: joinWithCensusData( violationsByCensusArea, “B01003”). See 'R/analysis/census_analysis.R' for some examples.

#Preparing to Contribute - Add your name to the List of Names Test Script.R
1. Fork this repo  
2. Create a new project in RStudio from [version control](http://i0.wp.com/www.datasurg.net/wp-content/uploads/2015/07/7_new_project.jpg?zoom=2&resize=456%2C328) and pull in your repo  
3. Add your name to the "List of Names Test Script"  
4. Commit your changes  
5. Push your changes up to Github  
6. Issue a pull request to merge your updates with the master (base) 