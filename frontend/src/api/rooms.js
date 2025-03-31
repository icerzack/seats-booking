import axios from 'axios';

const API_URL = '/api/v1';

export const getAllRooms = async (page = 0, size = 20, sort = []) => {
    const response = await axios.get(`${API_URL}/rooms`, {
        params: { page, size, sort }
    });
    return response.data;
};