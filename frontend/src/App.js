import React from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import HomePage from './pages/HomePage';
import BookingPage from './pages/BookingPage';
import RoomsPage from './pages/RoomsPage';

const App = () => {
    return (
        <Router>
            <div className="container">
                <Routes>
                    <Route path="/" element={<HomePage />} />
                    <Route path="/bookings" element={<BookingPage />} />
                    <Route path="/rooms" element={<RoomsPage />} />
                </Routes>
            </div>
        </Router>
    );
};

export default App;