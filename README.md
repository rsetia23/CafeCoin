# CafeCoin Collective Web App

## Credits and key links

This project was completed by Andrew Fielding, Mohamed Karim Kane, Josh Len, and Rahul Setia. It was based on a template repository provided by our professor, Mark Fontenot. You can access the template repository through your browser [here](https://github.com/NEU-CS3200/25S-Project-Template), and you can access our repository [here](https://github.com/rsetia23/CafeCoin).

To view the video demo of our web app, please click ([here])

## Introduction

This repo contains the files necessary to run the preliminary CafeCoin Collective web app, created for the Spring 2025 CS3200 Intro to Databases final project. 

The idea for CafeCoin was inspired by a love for the charm and quality products produced by small and independent business, and an appreciation for the convenience and familiarity of national brands. CafeCoin is an innovative data-driven application that creates and maintains rewards profiles for consumers who visit independent coffee shops and cafes that are within the CafeCoin Collective. The app allows qualifying cafes to join a network of other local small businesses, forming a consortium of independent shops where consumers can use a single user profile to obtain Coins (rewards points) that may be redeemed for rewards at any shop within the network. CafeCoin helps businesses compete directly with the powerful loyalty programs driving traffic to large national chains, increasing organic digital exposure, providing new marketing opportunities, and boosting data literacy. For coffee drinkers, it provides a new incentive to support a local business rather than a national brand–instead of feeling locked into visiting Starbucks to accumulate points, coffee lovers can support individual cafes and still access the convenience and financial benefits of a broad rewards network. 

Put simply, with CafeCoin, customers can save money, try new coffee shops, and track their spending habits, while business owners can gain access to powerful tools to track information about their store, understand its performance, and expand its clientele. While our implementation does not yet have all the features necessary to deploy and operate the system at national scale, it provides several key functionalities for each of the finished app's main user types, including cafe customers, cafe owners, and CafeCoin Collective data analysts and administrators. 

You are free to copy, modify, distribute, and otherwise use CafeCoin for any internal Northeastern purpose. Please contact the owners for permission to share this file elsewhere. 

## What our implementation does (what it's good for right now)

Our implementation allows a customer to view (and reload) their cash balance, view their Coin balance (our reward offering), examine lifetime spending stats and monthly spending trends, and view an interactive map of CafeCoin Collective members, including recommendations for stores that match their saved preferences. It allows a cafe owner to add to, edit, and delete from their stored menu items, see how well previously designated reward items performed, and view the contact information of customers who have signed up as communications subscribers for their store. The app allows a CafeCoin data analyst to view system-wide KPIs, compare individual stores' performance, and view insights from the Collective's list of "leads"--stores it might try to recruit to join its system in the future. Finally, it allows a system administrator to deprecate or delete old customer and merchant data from the system, send and track alerts pertaining to system functionality (such as outage and maintenance notifications), and track and handle customer complaints by manually updating customer data and information and/or performing direct outreach to the complaining customer. 

## Prerequisites and installations

Before running the CafeCoin web app in your browser, you will need some prerequisites: 
- A GitHub Account
- A terminal-based git client or GUI Git client such as GitHub Desktop or the Git plugin for VSCode.
- VSCode with the Python Plugin
- A distribution of Python running on your laptop. The distro supported by the course is Anaconda or Miniconda.
- Docker Desktop (used to run the containers via `docker-compose.yaml`)
- **Optionally**: DataGrip for database exploration

Once you have cloned the project repo and before attempting to execute the code or launch the web app, you'll need to install dependencies, which differ for the front and backends. **The Dockerfiles in the codebase should automatically handle the installation for you**, but it can also be accomplished manually using our requirements.txt files and the terminal: 
- Navigate to the project root (`cd /path/to/project_folder`)
- Navigate to the api directory within the project folder (`cd api`)
- Install dependencies (`pip install -r requirements.txt`)
- Navigate to the app directory within the project folder (`cd app/src`)
- Install dependencies (`pip install -r requirements.txt`)
- Navigate back to the project directory (`cd /path/to/project_folder`)

## Project Components

The project has three major components that each run in their own separate Docker Containers:

- The frontend of the app, designed with Streamlit, in the `./app` directory
- The backend of the app (its data access layer, a REST api built with Flask) in the `./api` directory
- A MySQL Database that will be initialized with the SQL script file in the `./database-files` directory

## Getting started

1. Set up the `.env` file in the `./api` folder based on the `.env.template` file. Copy the template file and rename it to `.env` first. 
1. In the newly created file, choose some password that will be memorable to you. Type it into the appropriate line and save the file. 
1. You should be ready to start the Docker containers now. Open the Docker desktop app, and then use the following commands in your terminal to work with the containers:
   1. `docker compose up -d` to start all the containers in the background
   1. `docker compose down` to shutdown and delete the containers
   1. `docker compose up db -d` only start the database container (replace db with api or app for the other two services as needed)
   1. `docker compose stop` to "turn off" the containers but not delete them.
1. After spining up the containers, verify that they are running in Docker Desktop. If any container is not running, open the log to identify any errors. The database container will automatically execute the project's .sql file.

**Note:** You can also use the Docker Desktop GUI to start and stop the containers after the first initial run.

## Connecting the project to DataGrip for the first time

1. Once you have spun the containers up, open the DataGrip app and create a new **MySQL** data source. 
1. Change the port mapping for the new data source to **3200** (see `./app/docker-compose.yaml` for all port mapping information)
1. Paste the password you created in your `.env` file into the password field. Use `root` as the user. 
1. Test connection and, if successful, click Apply. 
1. Introspect the CafeCoin database and examine the database structure and sample data, as generated from `./database-files/CafeCoinFinal.sql`

## A note on auth and user access

In most applications, when a user logs in, they assume a particular role. For instance, when one logs in to a stock price prediction app, they may be a single investor, a portfolio manager, or a corporate executive (of a publicly traded company). Our app uses Role-based Access Control, or **RBAC** for short, where you can choose whether to log in as a customer, a merchant, a data administrator, or a data analyst. You can then peruse that user's webpages and functionalities. For the purposes of the app's demonstration, we have pre-selected one specific user of each type so you can view and use the web app as a real user would. We define which users are part of the demo app via the session state in `./app/src/Home.py`. 

We implement a simple RBAC system in Streamlit but we do not implement any user authentication (usernames and passwords). To see the frontend code that produces every page, navigate to `./app/src/pages` and peruse the python scripts there. Pages associated with the Customer user type start with a `0`, pages associated with the Merchant user type start with `1`, pages associated with the Administrator user type start with `2`, and pages associated with the Analyst user type start with `3`. To see how the Home page and user selection/page navigation process works under the hood, navigate to `./app/src/Home.py`. 

## Troubleshooting

### MacOS "Resource deadlock avoided" error
Some team members operating on MacOS have encountered an OSError referencing a **resource deadlock**, though the error's appearance is inconsistent and we have not yet identified the root of the bug. If this happens, we have had success trying the following steps: 
1. Backup any uncommited local changes
1. Delete your local copy of the repo
1. Re-clone the repository:
  - `git clone https://github.com/rsetia23/CafeCoin.git /path/to/location/New_Name`
1. Change to the newly re-cloned repo directory and proceed

**If errors persist**: 
- Optionally try the command `streamlit cache clear` to clear Streamlit's cache
- Email the developers

## Notes, further documentation, reporting problems and questions

Please note that **all** sample data generated for the project is fake. We generated our data with Mockaroo, and performed some manual cleanup to resolve dependency issues and ensure the data makes logical sense with our schema. The database and sample data load without issue, although there may still be some small problems with the data intuitively (eg not functionally). While we worked with the sample data as much as possible to ensure consistency with the logic of our schema, it is likely not perfect. We built the dataset under the assumption that is a snapshot of data, and it therefore does not represent all data since the "beginning" of the app's existence. 

We provide additional brief README/documentation files in the `./app/src/assets`, `./app/src/modules`, and `./database-files` directories. You will find that the front and backend code is well-documented inline with comments. If you would like to view our REST API Matrix (akin to a basic API documentation) you can find that [here](https://docs.google.com/document/d/1InAFlM4QcwDRLuhxHaO5qN1LR6GPRwXFz3yjTHctssA/edit?usp=sharing). Please note that not all resources in the documentation have been implemented for this project. You can see which endpoints have associated routes by exploring the routes folders under `./api/backend`. 

For any issues with setup and starting the app, please reference Dr. Fontenot's CS3200 Project Tutorials playlist on YouTube [here](https://www.youtube.com/playlist?list=PL_QnMemFdCzVy65mBYvomx0u-9y0tIq7y). To view the video demo of our project, please click [here](link). If there are any questions about our project idea or structure, issues or bugs with the code, or if you have suggestions to expand the project, please email the developers. You can contact us at: 
- fielding.a@northeastern.edu
- kane.mo@northeastern.edu
- len.j@northeastern.edu
- setia.ra@northeastern.edu

## Acknowledgements

We are grateful for the work all the TAs and Dr. Fontenot put into this class all semester to help us get to the point of producing this project. We're proud of our work, but understand that we couldn't have done it without all the time and dedication the team puts into lessons, grading, and office hours. You guys rock! 