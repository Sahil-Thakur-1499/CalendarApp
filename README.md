# CalendarApp

CalendarApp is an iOS application built using Swift and SwiftUI that integrates with Google Calendar API to manage events. Users can view, add, and manage their events in a user-friendly interface.

## Features

- **View Events**: Displays all events for the selected month in a scrollable view.
- **Add Events**: Allows users to add new events to their Google Calendar.
- **View Event Details**: Users can view detailed information about specific events.
- **Month/Year Picker**: Provides an easy-to-use month and year picker to navigate through the calendar.
- **Google Sign-In Integration**: Secure authentication using Google Sign-In.
- **Alerts**: Displays alerts for errors and important information.

## Usage
- Sign In: Sign in with your Google account using Google Sign-In.
- View Calendar: View the calendar to see events for the selected month. The current month is displayed by default.
- Select Date: Tap on a date to view events or add a new event.
- Add Event: Tap the "Add Event" button to add a new event for the selected date.
- Month/Year Picker: Tap the calendar icon in the header to open the month/year picker and navigate to a different month.
- Event Details: Tap on an event to view its details.

## Architecture

The CalendarApp is built using the MVVM (Model-View-ViewModel) architecture pattern. This architecture helps in separating the business logic from the UI, making the codebase more modular, testable, and maintainable.

### MVVM Components

1. **Model**: Represents the data and business logic of the application. In this app, the `GTLRCalendar_Event` model represents an event in the Google Calendar.

2. **View**: The UI components that display the data and interact with the user. In this app, SwiftUI views such as `CalendarView`, `AddEventView`, and `MonthYearPickerView` represent the view layer.

3. **ViewModel**: Acts as a bridge between the Model and the View. It retrieves data from the Model and prepares it for the View. The ViewModel also handles user interactions and updates the Model. In this app, `CalendarViewModel` is the main ViewModel that manages the state and logic of the calendar.

### App Structure

- **GoogleSignInManager**: A singleton class that manages Google Sign-In and API requests. It handles authentication and interaction with the Google Calendar API to fetch and create events.

- **CalendarView**: This is the main view that displays the calendar and handles user interactions. It uses the `CalendarViewModel` to fetch events, update the selected date, and navigate between months.

- **CalendarViewModel**: This view model is responsible for fetching events from the Google Calendar API, managing the state of the selected date and month, and handling user interactions such as adding new events or updating the selected date.

- **AddEventView**: A view that provides a form for users to add new events to their Google Calendar.

- **AddEventViewModel**: A view model that is responsible for creating event on user's Google Calendar and sends the event back to Calendar View.

- **EventDetailView**: A view that displays detailed events from their Google Calendar.

- **EventDetailViewModel**: A view model that converts the GTLRCalendar_Event data to data that is being used by Event Detail View. 

- **MonthYearPickerView**: A custom view that allows users to pick a month and year.

- **StringConstants**: A struct that contains all the string constants used throughout the app. This ensures consistency and ease of maintenance for all static strings in the application.
