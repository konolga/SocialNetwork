# SocialNetwork

Relational Databases and SQL

The project is to describe a social network web site, storing data on Users, their posts, images, friends and groups, with the support of the following points:

### USERS 
 – have basic info, can create groups, be members of the groups, create Publishes, be tagged on pictures, can like Publishes.

### GROUPS 
– created by one user, but can have many members (other users). Creator is not necessary member of the group. 

### PUBLISH 
– is the common object for Pictures, Posts and Albums

### POST 
– is type of PUBLISH. Post is created by user, can have picture or without picture

### ALBUM 
- is type of PUBLISH. Contains different pictures.
Difference between pictures for post, album and just picture without post: is PictureType key

### MESSAGES 
– can be sent from one user to another (receiver and sender)



## There are 3 files for this project: 

1_CreateDataBaseTables

2_InsertData

3_Queries

You can run them consequentially to create a new database SocialNetwork with sample data inside. 

Queries of the project requer to show information for specific user, so in most cases I declare variable  @SpecificUserID.

For every query I suggested @SpecificUserID that has enough data to display how query works.
