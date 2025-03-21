package vasilkov.seats_booking_backend.api.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;

import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TimeSlotDTO {
    @JsonFormat(pattern = "HH:mm")
    private LocalTime startTime;

    @JsonFormat(pattern = "HH:mm")
    private LocalTime endTime;

    private boolean isBooked;

    public boolean equals(final Object o) {
        if (o == this) return true;
        if (!(o instanceof TimeSlotDTO)) return false;
        final TimeSlotDTO other = (TimeSlotDTO) o;
        if (!other.canEqual((Object) this)) return false;
        final Object this$startTime = this.getStartTime();
        final Object other$startTime = other.getStartTime();
        if (this$startTime == null ? other$startTime != null : !this$startTime.equals(other$startTime)) return false;
        final Object this$endTime = this.getEndTime();
        final Object other$endTime = other.getEndTime();
        if (this$endTime == null ? other$endTime != null : !this$endTime.equals(other$endTime)) return false;
        if (this.isBooked() != other.isBooked()) return false;
        return true;
    }

    protected boolean canEqual(final Object other) {
        return other instanceof TimeSlotDTO;
    }

    public int hashCode() {
        final int PRIME = 59;
        int result = 1;
        final Object $startTime = this.getStartTime();
        result = result * PRIME + ($startTime == null ? 43 : $startTime.hashCode());
        final Object $endTime = this.getEndTime();
        result = result * PRIME + ($endTime == null ? 43 : $endTime.hashCode());
        result = result * PRIME + (this.isBooked() ? 79 : 97);
        return result;
    }

    public String toString() {
        return "TimeSlotDTO(startTime=" + this.getStartTime() + ", endTime=" + this.getEndTime() + ", isBooked=" + this.isBooked() + ")";
    }
}
