# SocialNetwork

Relational Databases and SQL

The project is to describe a social network web site, storing data on Users, their posts, images, friends and groups, with the support of the following points:

### USERS 
Information on a User, its Basic Info, Hometown, workplace, Contact Info, etc.

Each User has many Friends which are also users of the site.

User can join to groups and create new ones.

User can share his thoughts and feeling to his friends. (create Publishes)

User can load an Album of pictures.

Users can be in relationship with other users.

Can be tagged on pictures.

Can like Publishes.


### GROUPS 
Each user can create a group and be the group manager.

Every user can join any group.

created by one user, but can have many members (other users).

Creator is not necessary member of the group. 


### PUBLISH 
– is the common object for Pictures, Posts and Albums

### POST 
Post is a type of PUBLISH. Post is created by user, can have picture or without picture

A Post can be liked by users.


### ALBUM
Album is a type of PUBLISH. 

Difference between pictures for post, album and just picture without post: is PictureType key

Each Album has a name, description.

Album is owned by a user.

There are many pictures in an album.

### PICTURES
Picture is a type of PUBLISH. 

A Picture can be tagged by users.

A Picture belongs to only one album.

### MESSAGES 
can be sent from one user to another (receiver and sender).

Each message has a subject.



## There are 3 files for this project: 

1_CreateDataBaseTables

2_InsertData

3_Queries

You can run them consequentially to create a new database SocialNetwork with sample data inside. 

Queries of the project requer to show information for specific user, so in most cases I declare variable  @SpecificUserID.

For every query I suggested @SpecificUserID that has enough data to display how query works.
