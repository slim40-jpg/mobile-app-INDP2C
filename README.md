# TuniVoyage System

TuniVoyage is a travel management platform that connects **users**, **travel agencies**, and **administrators** in a single system. It allows users to explore trips, view detailed itineraries, manage their travel history, and write reviews, while agencies can publish and manage trips. Administrators oversee the platform by managing users, agencies, and trip approvals.

## 📌 Overview

The system is designed around three main actors:

* **User**: Travelers who browse, book, and review trips.
* **Agency**: Travel agencies that create, publish, and manage trips.
* **Admin**: Platform administrators who manage users, agencies, and approve trips.

The functionality is modeled using a **UML Use Case Diagram**, showing interactions between actors and the TuniVoyage system.

## 👤 User Features

Users can:

* Sign up and log in
* View available trips
* Filter trips by category
* View detailed trip information

    * View trip stops
    * View trip roadmap and map
* View the list of agencies
* View agency profiles

    * View upcoming trips
* Write reviews
* View profile
* View trip history

    * View past trips

> Some features use **include** relationships (mandatory sub-features) and **extend** relationships (optional or conditional features), as represented in the UML diagram.

## 🏢 Agency Features

Agencies can:

* Publish new trips

    * Create a trip roadmap
* Edit existing trips
* Manage past trips
* View reviews on their trips

These features allow agencies to fully control their trip offerings and monitor traveler feedback.

## 🛡️ Admin Features

Admins can:

* Manage users
* Manage agencies
* Approve or reject trips

    * View published trips

Admins ensure quality control and proper operation of the platform.

## 🧩 UML Use Case Diagram

The UML use case diagram illustrates:

* Actor-to-system interactions
* Relationships between use cases

    * **<<include>>** for required sub-processes
    * **<<extend>>** for optional behaviors

> 📷 *You can find the UML use case diagram image in the project documentation or assets folder.*

##  Technologies 

* Frontend: Flutter (Mobile Application)
* Backend: Firebase 
* Database: Firestore / Auth DataBase
* Design: UML, Figma

## 📄 License

This project is licensed under the terms specified in the `LICENSE` file.

---

**TuniVoyage** aims to simplify travel discovery and management while ensuring transparency and quality through reviews and admin validation.
