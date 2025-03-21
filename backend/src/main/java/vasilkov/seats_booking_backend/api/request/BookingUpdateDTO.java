package vasilkov.seats_booking_backend.api.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BookingUpdateDTO {
    private UUID roomId;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String comment;
}
