package vasilkov.seats_booking_backend.api.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BookingDto implements Serializable {
    UUID id;
    String roomId;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    LocalDateTime startTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    LocalDateTime endTime;
    String comment;
}