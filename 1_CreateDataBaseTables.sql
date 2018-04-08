

------------------------------------------------------------------------------------
--create database and tables--------------------------------------------------------
------------------------------------------------------------------------------------

create  database SocialNetwork
go
use SocialNetwork

create table NetworkUsers(
UserID INT primary key,
UserFirstName varchar(20) not null,
UserLastName varchar(20) not null,
Hometown varchar(50) not null,
DateOfBirth date not null,
WorkPlace varchar(50) not null,
ContactEmail varchar(50) not null)

--GROUPS---------------------------------------
--User can join to groups and create new ones--
--Each user can create a group and be the group manager--

create table Groups(
GroupID int primary key,
GroupName varchar(50) not null,
DateOfCreation date not null,
CreatorID int references NetworkUsers (UserID))

create table GroupMembership(
GroupID int references Groups (GroupID),
UserID INT references NetworkUsers(UserID),  
primary key  (UserID, GroupID))


--MESSAGES-------------------------------------
--Users can send messages to other users--
create table UserMessages(
SenderID INT references NetworkUsers(UserID),
ReceiverID INT references NetworkUsers(UserID),
Msg_Subject varchar(50),
Msg_Body varchar(250) not null,
Msg_Date date not NULL,
constraint MessageStatus check (SenderID<>ReceiverID)) --user can't sent email himself

--FRIENDSHIP-------------------------------------
--Each User has many Friends which are also users of the site--
create table Friendship(
UserID1 INT references NetworkUsers(UserID),
UserID2 INT references NetworkUsers(UserID),
Relationship varchar(50), --Users can be in relationship with other users
constraint PK_Friendship  primary key  (UserID1, UserID2),
constraint RelationshipStatus check (UserID1<>UserID2 and Relationship in ('marriage', 
'sibling', 'colleague', null)))


--PUBLISH------------------------------------------
--User can share his thoughts and feeling to his friends--
--Publish can be one of the types: album, post or picture--
--publish ID is unique for all pites (cannot repeat twice)-- 
create table Publish(
PublishID INT primary key,
UserID INT references NetworkUsers(UserID),
DateOfPublish date not NULL,
PublishType VARCHAR(4) not null default 'post' CHECK(PublishType in ('post', 'pict', 'albu')),
unique (PublishID, PublishType))

create table Picture(
PictureID INT PRIMARY KEY REFERENCES Publish(PublishID),
PublishType VARCHAR(4) default 'pict' CHECK (PublishType = 'pict'),
PictureType VARCHAR(2) default 'no' CHECK (PictureType IN( 'no','po','al')),
unique (PictureID, PictureType),
foreign key (PictureID, PublishType) references Publish (PublishID, PublishType),
PictureURL varchar(250) not NULL)


create table Post(
PostID INT PRIMARY KEY REFERENCES Publish(PublishID),
PublishType VARCHAR(4) default 'post' CHECK (PublishType = 'post'),
FOREIGN KEY (PostID, PublishType) REFERENCES Publish (PublishID, PublishType),
PictureType VARCHAR(2) DEFAULT 'po' CHECK (PictureType IN ('po', null)), --if post without picture
PictureID INT REFERENCES Picture(PictureID) null,
FOREIGN KEY (PictureID, PictureType) REFERENCES Picture (PictureID, PictureType),
PostText VARCHAR(500) NOT NULL)

create table Album(
AlbumID INT PRIMARY KEY REFERENCES Publish(PublishID),
PublishType VARCHAR(4) default 'albu' CHECK (PublishType = 'albu'),
FOREIGN KEY (AlbumID, PublishType) references Publish (PublishID, PublishType),
AlbumName VARCHAR(30) not null,
AlbumDescription VARCHAR(150) not null)

create table AlbumPictures(
PictureType VARCHAR(2) DEFAULT 'al' CHECK (PictureType ='al'),
PictureID INT references Picture(PictureID),
FOREIGN KEY (PictureID, PictureType) REFERENCES Picture (PictureID, PictureType),
AlbumID INT references Album(AlbumID),
CONSTRAINT PK_AlbumPict PRIMARY KEY (AlbumID,PictureID))


--TAG and LIKE---------------------------------------------
--one publish can have one like of one user--
--one user can be taged at one picture--

create table Likes(
UserID INT references NetworkUsers(UserID),
PublishID INT references Publish(PublishID),
primary key (UserID, PublishID),
UNIQUE (UserID, PublishID))

create table Tags(
UserID INT references NetworkUsers(UserID),
PictureID INT references Picture(PictureID),
primary key (UserID, PictureID),
UNIQUE (UserID, PictureID))


--INDEXES---------------------------------------------------
--for tables with the most data-----------------------------

create index index_AlbumPictures
on AlbumPictures (AlbumID,PictureID);

create index index_likes
on Likes (UserID, PublishID);

create index index_tages
on Tags (UserID, PictureID);